package luceneservice;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import javax.activation.MimetypesFileTypeMap;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.Term;
import org.apache.lucene.store.FSDirectory;
import org.wltea.analyzer.lucene.IKAnalyzer;

/**
 * 遍历Note文件系统并索引文件
 * @author Administrator
 */
public class NoteIndexer extends Indexer {

  private File dataDir;               // 要建(删)索引文件
  private String commitId;            // Note的提交commit_id
  private String type;                // 索引类型 Newest 和 Full

  NoteIndexer(String indexDir, String dataDir, String commitId, String type) throws IOException {
    this.indexDir = FSDirectory.open(new File(indexDir));
    this.dataDir = new File(dataDir);
    this.commitId = commitId;
    this.type = type;
  }

  NoteIndexer(String indexDir, String dataDir) throws IOException {
    this.indexDir = FSDirectory.open(new File(indexDir));
    this.dataDir = new File(dataDir);
  }

  /**
   * 检查文件是否存在，不存在抛异常
   * @param file 要被检测的文件
   * @throws IOException
   */
  private void checkFile(File file) throws IOException {
    if (!file.exists()) {
      throw new IOException(file + " does not exist!");
    }
  }

  /**
   * 对文件名进行检测，查找该文件名命名的文件是否存在
   * @param path
   * @throws IOException
   */
  private void checkFile(String path) throws IOException {
    checkFile(new File(path));
  }

  /**
   * 索引 
   * @return 返回索引文件数量
   * @throws IOException
   */
  public int index() throws IOException, CorruptIndexException, InterruptedException {
    checkFile(dataDir);
    String[] list = indexDir.listAll();
    boolean isEmpty = is_incremental(list);
    // 创建lucene索引 第三个参数是false，说明是增量索引，不会重写,仅是简单的将create参数设为false，会造成索引重复。
    setIndexWriter(isEmpty);
    writer.setUseCompoundFile(false);// Setting to turn on usage of a compound file when on.
    indexFileOrDirectory(isEmpty);
    int numIndexed = writer.numDocs();
    writer.optimize();
    writer.close();
    return numIndexed;
  }

  /**
   * 判断是否是进行增量索引,
   * 如果没有索引文件 就是重新建索引
   * @param list
   * @return 需要增量索引返回true
   */
  private boolean is_incremental(String[] list) {
    if (list.length == 0) {
      return true;
    }
    return false;
  }

  /**
   * 根据文件类型分别作不同的处理
   * @param isEmpty
   * @throws IOException
   */
  private void indexFileOrDirectory(boolean isEmpty) throws IOException {
    if (dataDir.isDirectory()) {
      indexDirectory(dataDir, isEmpty);
    } else if (dataDir.isFile()) {
      indexFile(dataDir, isEmpty);
    }
  }

  /**
   * 递归的方法，当找到一个目录的时候 调用
   * @param dir
   * @param isEmpty
   * @throws IOException
   */
  private void indexDirectory(File dir, boolean isEmpty) throws IOException {
    File[] files = dir.listFiles();
    for (int i = 0; i < files.length; i++) {
      File f = files[i];
      if (f.isDirectory() && !f.getName().endsWith(".git")) {
        indexDirectory(f, isEmpty);
      } else if (f.isFile()) { // 这里要判断文件格式
        indexFile(f, isEmpty);
      }
    }
  }

  /**
   * 索引一个文件
   * @param f
   * @param isEmpty
   * @throws IOException
   */
  private void indexFile(File f, boolean isEmpty) throws IOException {
    // 如果文件隐藏，不存在，不能被读取，不是文本文件 则 直接返回，不进行索引
    if (f.isHidden() || !f.exists() || !f.canRead() || notSupportType(f)) {
      return;
    }
    String filePath = f.getCanonicalPath();
    if (!isEmpty && isNewIndex()) {// 增量索引并且是最新的note时候，需要进行查看是否存在过，已存在的删除
      checkFileIndex(filePath);
    }
    System.out.println("Indexing " + f.getCanonicalPath());
    Document doc = new Document();
    doc.add(new Field("content", fileContent(new FileReader(f)), Field.Store.YES, Field.Index.ANALYZED, Field.TermVector.WITH_POSITIONS_OFFSETS)); // 索引文件内容
    doc.add(new Field("filename", f.getName(), Field.Store.YES, Field.Index.ANALYZED));                     // 索引文件名称
    doc.add(new Field("filepath", filePath, Field.Store.YES, Field.Index.NOT_ANALYZED));                    // 索引文件路径 但不分析 最终搜索的返回值
    doc.add(new Field("fileid", getFileId(filePath), Field.Store.YES, Field.Index.NOT_ANALYZED));          // 文件的唯一标示 不分析 更新删除用
    doc.add(new Field("noteid", getNoteId(filePath), Field.Store.YES, Field.Index.NOT_ANALYZED));          // note的id  删除note索引用
    doc.add(new Field("commitid", commitId, Field.Store.YES, Field.Index.NOT_ANALYZED));                   // 文件提交的commit_id 最终的返回值
    writer.addDocument(doc);
  }

  /**
   * 判断是否建立最新note的索引
   * @return
   */
  private boolean isNewIndex() {
    return type.equals(LuceneNotesServiceHandler.NOTE_NEWEST_TYPE);
  }

  /**
   * 读取文件内容
   * @param fileReader
   * @return
   * @throws IOException
   */
  private String fileContent(FileReader fileReader) throws IOException {
    BufferedReader br = new BufferedReader(fileReader);
    StringBuilder lines = new StringBuilder();
    String line = null;
    while ((line = br.readLine()) != null) {
      lines.append(line);
    }
    br.close();
    return lines.toString();
  }

  /**
   * 检查文档是否被索引过，如果是，删除先前索引中的记录
   * @param dataDir
   * @throws CorruptIndexException
   * @throws IOException
   */
  private void checkFileIndex(String dataDir) throws CorruptIndexException, IOException {
    writer.deleteDocuments(new Term("fileid", getFileId(dataDir)));
  }

  /**
   * 根据文件路径返回fileid 他的格式是 note_id 与 file的name组合体
   * @param filePath
   * @return
   */
  private String getFileId(String filePath) {
    // linux和wondows下路径的分隔符不一样
    //String[] strs = filePath.split("\\\\");
    String[] strs = filePath.split("/");
    if (isNewIndex()) {
      return strs[strs.length - 2] + strs[strs.length - 1];
    } else {
      return strs[strs.length - 2] + strs[strs.length - 1] + commitId;
    }
  }

  /**
   * 删除note索引的时候要用到得 id
   * @param filePath
   * @return
   */
  private String getNoteId(String filePath) {
    String[] strs = filePath.split("/");
    return strs[strs.length - 2];
  }

  /**
   * 判断文件类型，使用文件后缀名来判断。如果检测文件流中是否存在0x00-0x07，需要读一遍文件
   * @param f
   * @return
   * @throws IOException
   */
  private boolean notSupportType(File f) throws IOException {
    File cloneFile = new File(f.getCanonicalPath().toLowerCase());
    MimetypesFileTypeMap mft = new MimetypesFileTypeMap();
    mft.addMimeTypes("image/png png");
    mft.addMimeTypes("application/zip zip");
    mft.addMimeTypes("application/x-tar tar");
    mft.addMimeTypes("audio/mpeg mp3 mpeg3");
    mft.addMimeTypes("application/pdf pdf");
    String mimeType = mft.getContentType(cloneFile);
    if (mimeType.equals("application/octet-stream") || mimeType.equals("text/plain")) {
      return false;
    }
    return true;
  }

  /**
   * 对note的两套索引进行处理
   * @param deletePath
   * @return
   * @throws IOException
   */
  public boolean deleteIndex() throws IOException {
    writer = new IndexWriter(indexDir, new IKAnalyzer(), false, IndexWriter.MaxFieldLength.UNLIMITED);
    // 开始建立索引
    boolean res = deleteFileIndex();
    writer.optimize();
    writer.close();
    return res;
  }

  /**
   * 删除指定文件的索引
   * @param delteFile
   * @return
   */
  private boolean deleteFileIndex() {
    try {
      String path = dataDir.getCanonicalPath();
      writer.deleteDocuments(new Term("noteid", dataDir.getName()));
      System.out.println(path + "删除索引");
      return true;
    } catch (IOException iOException) {
      return false;
    }
  }
  
  /*
  public static void main(String[] args) throws Exception {
  // 测试时需要注意，window和linux路径的分隔符不一样
  String dataDirStr = "\\\\192.168.1.8\\root\\root\\mindpin_base\\note_repo\\notes";
  //String dataDirStr = "/root/mindpin_base/note_repo/notes";
  //String dataDirStr = "src\\data";
  String indexDirStr = "\\\\192.168.1.8\\root\\web\\2010\\lucene\\notes\\index";
  Indexer indexer = new Indexer(dataDirStr, indexDirStr);
  long start = new Date().getTime();
  int numIndexed = indexer.index();
  long end = new Date().getTime();

  System.out.println("Indexing " + numIndexed + " files took " + (end - start) + "milliseconds");
  }
   *
   */
}
