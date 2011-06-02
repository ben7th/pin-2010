package luceneservice.base;

import java.io.File;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import luceneservice.Main;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.wltea.analyzer.lucene.IKAnalyzer;

/**
 *
 * @author Administrator
 */
public abstract class Indexer {

  protected Directory index_dir;  // 索引目录

  public Indexer(File index_dir_file){
    try {
      this.index_dir = FSDirectory.open(index_dir_file);
    } catch (IOException ex) {
      System.out.println("FSDirectory open error.");
    }
  }

  /**
   * 检查索引目录是否被锁,如果被锁，解除锁定
   */
  public void forceUnlockIndex() throws IOException {
    if(IndexWriter.isLocked(index_dir)){
      IndexWriter.unlock(index_dir);
    }
  }

  /**
   * 返回Feed的索引目录是否为空
   * true 为空
   * false 不为空
   */
  public boolean isIndexDirEmpty() throws IOException {
    //listAll是返回所有索引文件名
    return index_dir.listAll().length == 0;
  }

  /**
   * 获取一个indexwriter实例，线程同步，互斥锁
   * @param is_rebuild 表示是否重建索引 true->重建索引 false->增量索引
   * @return
   */
  public IndexWriter getIndexWriter(boolean is_rebuild) throws IOException, InterruptedException {
    synchronized (Main.serverTransport) {
      while (true) {
        if (!IndexWriter.isLocked(index_dir)) {
          IndexWriter writer = new IndexWriter(index_dir, new IKAnalyzer(), is_rebuild, IndexWriter.MaxFieldLength.UNLIMITED);
          writer.setUseCompoundFile(false);// Setting to turn on usage of a compound file when on.
            //    writer.setMaxBufferedDocs(500);      //默认值(10)，内存中缓存的索引文件
            //    writer.setMergeFactor(1000);         //每向索引添加n个Document是，就会有一个新的segment在磁盘建立
            //    writer.setMaxMergeDocs(1000);        //一个segment能包含的最大的Document数量
          return writer;
        } else {
          Thread.sleep(50);
          Thread.yield();
        }
      }
    }
  }
}
