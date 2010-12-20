package luceneservice;

import java.io.IOException;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.store.Directory;
import org.wltea.analyzer.lucene.IKAnalyzer;

/**
 *
 * @author Administrator
 */
public class Indexer {

  protected IndexWriter writer; // 索引对象
  protected Directory indexDir;         // 索引目录

  /**
   * 检查索引目录是否被锁,如果被锁，解除锁定
   */
  protected void unlockIfIndexLocked() throws IOException {
    if(IndexWriter.isLocked(indexDir)){
      IndexWriter.unlock(indexDir);
    }
  }

  /**
   * 设置indexwriter
   * @param create 表示是否是增量索引（false=>是）
   * @return
   */
  protected void setIndexWriter(boolean create) throws CorruptIndexException, IOException, InterruptedException {
    synchronized (Main.serverTransport) {
      while (true) {
        if (!IndexWriter.isLocked(indexDir)) {
          if (writer == null) {
            writer = new IndexWriter(indexDir, new IKAnalyzer(), create, IndexWriter.MaxFieldLength.UNLIMITED);
            writer.setUseCompoundFile(false);// Setting to turn on usage of a compound file when on.
            //    writer.setMaxBufferedDocs(500);      //默认值(10)，内存中缓存的索引文件
            //    writer.setMergeFactor(1000);         //每向索引添加n个Document是，就会有一个新的segment在磁盘建立
            //    writer.setMaxMergeDocs(1000);        //一个segment能包含的最大的Document数量
          }
          return;
        } else {
          Thread.sleep(80);
          Thread.yield();
        }
      }
    }
  }
}
