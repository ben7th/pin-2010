/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package lucene;

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
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.wltea.analyzer.lucene.IKAnalyzer;

/**
 * 遍历文件系统和索引文件
 * @author Administrator
 */
public class NoteIndexer extends Indexer{

  private Directory allIndexDir;      // 所有的与commit相关的索引
  private Directory newestIndexDir;   // 所有的最新的index的索引
  private File dataDir;
  private String commitId;

  NoteIndexer(String dataDir, String indexDir) throws IOException {
    this.allIndexDir = FSDirectory.open(new File(indexDir));
    this.dataDir = new File(dataDir);
  }

  NoteIndexer(String dataDir, String indexDir, String newIndexDir, String commitId) throws IOException {
    this.allIndexDir = FSDirectory.open(new File(indexDir));
    this.newestIndexDir = FSDirectory.open(new File(newIndexDir));
    this.dataDir = new File(dataDir);
    this.commitId = commitId;
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
   * 索引 针对note的两套索引，全部的索引，以及最新的索引
   * @return
   * @throws IOException
   */
  public int index() throws IOException {
    checkFile(dataDir);
    // 创建lucene索引 第三个参数是false，说明是增量索引，不会重写,仅是简单的将create参数设为false，会造成索引重复。
    int num1 = indexDir(allIndexDir, "common");
    int num2 = indexDir(newestIndexDir, "new");
    return num1 + num2;
  }

  /**
   * 所以各个目录
   * @param indexDirTmp
   * @param sign 来区别是全部索引，还是最新note的索引
   * @return 返回索引文件数量
   * @throws IOException
   */
  private int indexDir(Directory indexDirTmp, String sign) throws IOException {
    String[] list = indexDirTmp.listAll();
    boolean isEmpty = is_incremental(list);
    // 开始建立索引
    IndexWriter writer = new IndexWriter(indexDirTmp, new IKAnalyzer(), isEmpty, IndexWriter.MaxFieldLength.UNLIMITED);
    writer.setUseCompoundFile(false);// Setting to turn on usage of a compound file when on.
    indexFileOrDirectory(writer, dataDir, isEmpty, sign);
    int numIndexed = writer.numDocs();
    writer.optimize();
    writer.close();
    return numIndexed;
  }

  /**
   * 判断是否是进行增量索引,
   * 如果没有索引文件，或者 要索引的文件就是notes的根目录 就是重新建索引
   * @param list
   * @return 需要增量索引返回true
   */
  private boolean is_incremental(String[] list) {
    boolean sameDir = new File(LuceneServiceHandler.DATA_PATH).equals(dataDir);
    boolean noIndexFile = (list.length == 0);
    if (sameDir || noIndexFile) {
      return true;
    }
    return false;
  }

  /**
   * 根据文件类型分别作不同的处理
   * @param writer
   * @param dir
   * @param isEmpty
   * @param sign
   * @throws IOException
   */
  private void indexFileOrDirectory(IndexWriter writer, File dir, boolean isEmpty, String sign) throws IOException {
    if (dir.isDirectory()) {
      indexDirectory(writer, dir, isEmpty, sign);
    } else if (dir.isFile()) {
      indexFile(writer, dir, isEmpty, sign);
    }
  }

  /**
   * 递归的方法，当找到一个目录的时候 调用
   * @param writer
   * @param dir
   * @param isEmpty
   * @param sign
   * @throws IOException
   */
  private void indexDirectory(IndexWriter writer, File dir, boolean isEmpty, String sign) throws IOException {
    File[] files = dir.listFiles();
    for (int i = 0; i < files.length; i++) {
      File f = files[i];
      if (f.isDirectory() && !f.getName().endsWith(".git")) {
        indexDirectory(writer, f, isEmpty, sign);
      } else if (f.isFile()) { // 这里要判断文件格式
        indexFile(writer, f, isEmpty, sign);
      }
    }
  }

  /**
   * 用lucene去索引一个文件
   * @param writer
   * @param f
   * @param isEmpty
   * @param sign
   * @throws IOException
   */
  private void indexFile(IndexWriter writer, File f, boolean isEmpty, String sign) throws IOException {
    // 如果文件隐藏，不存在，不能被读取，不是文本文件 则 直接返回，不进行索引
    if (f.isHidden() || !f.exists() || !f.canRead() || notSupportType(f)) {
      return;
    }
    String fileName = f.getName();
    String filePath = f.getCanonicalPath();
    if (!isEmpty && isNewIndex(sign)) {// 增量索引并且是最新的note时候，需要进行查看是否存在过，已存在的删除
      checkFileIndex(writer, filePath, sign);
    }
    System.out.println("Indexing " + f.getCanonicalPath());
    String fileid = getFileId(filePath, sign);
    String noteid = getNoteId(filePath);
    Document doc = new Document();
    doc.add(new Field("content", fileContent(new FileReader(f)), Field.Store.YES, Field.Index.ANALYZED, Field.TermVector.WITH_POSITIONS_OFFSETS)); // 索引文件内容
    doc.add(new Field("filename", fileName, Field.Store.YES, Field.Index.ANALYZED)); // 索引文件名称
    doc.add(new Field("filepath", filePath, Field.Store.YES, Field.Index.NOT_ANALYZED)); // 索引文件路径 但不分析
    doc.add(new Field("fileid", fileid, Field.Store.YES, Field.Index.NOT_ANALYZED)); // 文件的唯一标示 不分析
    doc.add(new Field("noteid", noteid, Field.Store.YES, Field.Index.NOT_ANALYZED)); // note的id
    doc.add(new Field("commitid", commitId, Field.Store.YES, Field.Index.NOT_ANALYZED)); // 文件提交的commit_id
    writer.addDocument(doc);
  }

  /**
   * 判断是否建立最新note的索引
   * @param sign
   * @return
   */
  private boolean isNewIndex(String sign) {
    return sign.equals("new");
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
   * @param writer
   * @param dataDir
   * @param sign
   * @throws CorruptIndexException
   * @throws IOException
   */
  private void checkFileIndex(IndexWriter writer, String dataDir, String sign) throws CorruptIndexException, IOException {
    writer.deleteDocuments(new Term("fileid", getFileId(dataDir, sign)));
  }

  /**
   * 根据文件路径返回fileid 他的格式是 note_id 与 file的name组合体
   * @param filePath
   * @param sign
   * @return
   */
  private String getFileId(String filePath, String sign) {
    // linux和wondows下路径的分隔符不一样
    //String[] strs = filePath.split("\\\\");
    String[] strs = filePath.split("/");
    if (isNewIndex(sign)) {
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
    MimetypesFileTypeMap mimetypesFileTypeMap = new MimetypesFileTypeMap();
    mimetypesFileTypeMap.addMimeTypes("image/png png");
    mimetypesFileTypeMap.addMimeTypes("application/zip zip");
    mimetypesFileTypeMap.addMimeTypes("application/x-tar tar");
    mimetypesFileTypeMap.addMimeTypes("audio/mpeg mp3 mpeg3");
    mimetypesFileTypeMap.addMimeTypes("application/pdf pdf");
    String mimeType = mimetypesFileTypeMap.getContentType(cloneFile);
    if (mimeType.equals("application/octet-stream") || mimeType.equals("text/plain")) {
      return false;
    }
    return true;
  }

  /**
   * 对note的两套索引进行处理
   * @param deletePath
   * @return 删除成功返回true
   * @throws IOException
   */
  public boolean deleteIndex(String deletePath) throws IOException {
    boolean a = deleteOneIndex(allIndexDir, deletePath);
    boolean b = deleteOneIndex(newestIndexDir, deletePath);
    return a && b;
  }

  /**
   * 删除指定路径的索引
   * @param indexDirTmp
   * @param deletePath
   * @return
   * @throws IOException
   */
  private boolean deleteOneIndex(Directory indexDirTmp, String deletePath) throws IOException {
    File deleteFile = new File(deletePath);
    IndexWriter writer = new IndexWriter(indexDirTmp, new IKAnalyzer(), false, IndexWriter.MaxFieldLength.UNLIMITED);
    // 开始建立索引
    boolean res = deleteFileIndex(writer, deleteFile);
    writer.optimize();
    writer.close();
    return res;
  }

  /**
   * 删除指定文件的索引
   * @param writer
   * @param delteFile
   * @return 删除成功返回true
   */
  private boolean deleteFileIndex(IndexWriter writer, File delteFile) {
    try {
      String path = delteFile.getCanonicalPath();
      writer.deleteDocuments(new Term("noteid", delteFile.getName()));
      System.out.println(path + "删除索引");
      return true;
    } catch (IOException iOException) {
      return false;
    }
  }
}
