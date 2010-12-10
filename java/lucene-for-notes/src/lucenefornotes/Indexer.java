/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package lucenefornotes;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Date;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Version;
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

    String dataDirStr = "\\\\192.168.1.8\\root\\root\\mindpin_base\\note_repo\\notes";
    //String dataDirStr = "src\\data";
    String indexDirStr = "src\\index";
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
    boolean isEmpty =  (list.length == 0) ? true : false;
    //boolean isEmpty = true;
    System.out.println(isEmpty);
    IndexWriter writer = new IndexWriter(indexDir, new IKAnalyzer(), isEmpty, new IndexWriter.MaxFieldLength(25000));
    writer.setUseCompoundFile(false);// 设置打开使用复合文件 Setting to turn on usage of a compound file.

    indexFileOrDirectory(writer, dataDir);

    int numIndexed = writer.numDocs();
    writer.optimize();
    writer.close();

    return numIndexed;
  }

  // 根据是文件还是目录分别作不同的处理
  private void indexFileOrDirectory(IndexWriter writer, File dir) throws IOException {
    if (dir.isDirectory()) {
      indexDirectory(writer, dir);
    } else {
      indexFile(writer, dir);
    }
  }

  // 递归的方法，当找到一个目录的时候 调用
  private void indexDirectory(IndexWriter writer, File dir) throws IOException {
    File[] files = dir.listFiles();
    for (int i = 0; i < files.length; i++) {
      File f = files[i];
      if (f.isDirectory() && !f.getName().endsWith(".git")) {
        indexDirectory(writer, f);
      } else if (f.getName().endsWith("")) { // 这里要判断文件格式
        indexFile(writer, f);
      }
    }
  }

  // 用lucene去索引一个文件
  private void indexFile(IndexWriter writer, File f) throws IOException {
    if (f.isHidden() || !f.exists() || !f.canRead()) {
      return;
    }
    System.out.println("Indexing " + f.getCanonicalPath());
    Document doc = new Document();
    doc.add(new Field("content", new FileReader(f))); // 索引文件内容
    doc.add(new Field("filename", f.getCanonicalPath(), Field.Store.YES, Field.Index.ANALYZED)); // 索引文件名称
    System.out.println(f.getCanonicalPath()+"在做索引");
    writer.addDocument(doc);
  }
}
