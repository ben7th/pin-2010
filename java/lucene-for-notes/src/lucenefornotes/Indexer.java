/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package lucenefornotes;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Date;
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
public class Indexer {

  private Directory indexDir;
  private File dataDir;

  Indexer(String dataDir, String indexDir) throws IOException {
    this.indexDir = FSDirectory.open(new File(indexDir));
    this.dataDir = new File(dataDir);
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
   
  public int index() throws IOException {
    if (!dataDir.exists()) {
      throw new IOException(dataDir + " does not exist!");
    }

    // 创建lucene索引 第三个参数是false，说明是增量索引，不会重写
    // 仅是简单的将create参数设为false，操作不当可能造成索引重复。 
    String[] list = indexDir.listAll();
    boolean isEmpty = is_incremental(list);
    // 开始建立索引
    IndexWriter writer = new IndexWriter(indexDir, new IKAnalyzer(), isEmpty, new IndexWriter.MaxFieldLength(25000));
    writer.setUseCompoundFile(false);// 设置打开使用复合文件 Setting to turn on usage of a compound file.
    indexFileOrDirectory(writer, dataDir, isEmpty);
    int numIndexed = writer.numDocs();
    writer.optimize();
    writer.close();
    return numIndexed;
  }

  // 判断是否是进行增量索引
  // 如果没有索引文件，或者 要索引的文件就是notes的根目录 就是重新建索引
  private boolean is_incremental(String[] list) {
    boolean sameDir = new File(LuceneServiceHandler.DATA_PATH).equals(dataDir);
    boolean noIndexFile = (list.length == 0);
    if (sameDir || noIndexFile) {
      return true;
    }
    return false;
  }

  // 根据是文件还是目录分别作不同的处理
  private void indexFileOrDirectory(IndexWriter writer, File dir, boolean isEmpty) throws IOException {
    if (dir.isDirectory()) {
      indexDirectory(writer, dir, isEmpty);
    } else {
      indexFile(writer, dir, isEmpty);
    }
  }

  // 递归的方法，当找到一个目录的时候 调用
  private void indexDirectory(IndexWriter writer, File dir, boolean isEmpty) throws IOException {
    File[] files = dir.listFiles();
    for (int i = 0; i < files.length; i++) {
      File f = files[i];
      if (f.isDirectory() && !f.getName().endsWith(".git")) {
        indexDirectory(writer, f, isEmpty);
      } else if (f.getName().endsWith("")) { // 这里要判断文件格式
        indexFile(writer, f, isEmpty);
      }
    }
  }

  // 用lucene去索引一个文件
  private void indexFile(IndexWriter writer, File f, boolean isEmpty) throws IOException {
    if (f.isHidden() || !f.exists() || !f.canRead()) {
      return;
    }
    String fileName = f.getName();
    String filePath = f.getCanonicalPath();
    if (!isEmpty) {// 增量索引的情况下，检查文档
      checkFileIndex(writer, filePath);
    }
    System.out.println("Indexing " + f.getCanonicalPath());
    String fileid = getFileId(filePath);
    Document doc = new Document();
    doc.add(new Field("content", fileContent(new FileReader(f)), Field.Store.YES, Field.Index.ANALYZED, Field.TermVector.WITH_POSITIONS_OFFSETS)); // 索引文件内容
    doc.add(new Field("filename", fileName, Field.Store.YES, Field.Index.ANALYZED)); // 索引文件名称
    doc.add(new Field("filepath", filePath, Field.Store.YES, Field.Index.NOT_ANALYZED)); // 索引文件路径 但不分析
    doc.add(new Field("fileid", fileid, Field.Store.YES, Field.Index.NOT_ANALYZED)); // 文件的唯一标示 不分析
    writer.addDocument(doc);
  }

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

  // 检查文档是否被索引过，如果是，删除先前索引中的记录
  private void checkFileIndex(IndexWriter writer, String dataDir) throws CorruptIndexException, IOException {
    writer.deleteDocuments(new Term("fileid", getFileId(dataDir)));
  }

  // 根据文件路径返回fileid 他的格式是 note_id 与 file的name组合体
  private String getFileId(String filePath) {
    // linux和wondows下路径的分隔符不一样
   //String[] strs = filePath.split("\\\\");
    String[] strs = filePath.split("/");
    return strs[strs.length - 2] + strs[strs.length - 1];
  }
}
