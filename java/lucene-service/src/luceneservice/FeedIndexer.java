package luceneservice;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.Term;
import org.apache.lucene.index.IndexWriter;
import org.wltea.analyzer.lucene.IKAnalyzer;
import org.apache.lucene.store.LockObtainFailedException;

/**
 * Feed的索引操作
 * @author Administrator
 */
public class FeedIndexer extends Indexer {

  private ConfigFile cf; // 配置文件
  private Document doc;

  public FeedIndexer() {
    Main.checkOrMkdir(cf.getFeedIndexPath());
  }

  public FeedIndexer(ConfigFile cf) throws IOException {
    Main.checkOrMkdir(cf.getFeedIndexPath());
    this.cf = cf;
    this.indexDir = FSDirectory.open(new File(cf.getFeedIndexPath()));
  }

  public Feed makeOfResultSet(ResultSet set) throws SQLException {
    Feed feed = new Feed(set.getString("id"), set.getString("content"), set.getString("email"));
    return feed;
  }

  /**
   * 索引所有的feeds
   * @return
   * @throws ClassNotFoundException
   * @throws SQLException
   * @throws IOException
   * @throws CorruptIndexException
   * @throws InterruptedException
   */
  public int indexAllFeeds() throws ClassNotFoundException, SQLException, IOException, CorruptIndexException, InterruptedException {
    Connection connection = getFeedConnection();
    PreparedStatement stat = connection.prepareStatement("select * from feeds");
    stat.setFetchSize(Integer.MIN_VALUE);
    ResultSet set = stat.executeQuery();
    unlockIfIndexLocked();
    setIndexWriter(true);
    int i = 0;
    long begin = new Date().getTime();
    while (set.next()) {
      Feed feed = makeOfResultSet(set);
      indexFeedContent(feed);
      i++;
    }
    writer.optimize();
    writer.close();
    connection.close();
    long end = new Date().getTime();
    System.out.println(new StringBuffer("Good job and good luck OK ! indexed ").append(i).append(" feeds total cost ").append(end - begin).append(" millisecs."));
    return i;
  }

  /**
   * 索引feed的content内容
   * @param feed
   * @throws CorruptIndexException
   * @throws IOException
   */
  private void indexFeedContent(Feed feed) throws CorruptIndexException, IOException {
    System.out.println(new StringBuffer().append("indexing feed ").append(feed.getId()));
    doc = new Document();
    doc.add(new Field("id", feed.getId(), Field.Store.YES, Field.Index.NOT_ANALYZED));
    doc.add(new Field("email", feed.getEmail(), Field.Store.YES, Field.Index.NOT_ANALYZED));
    doc.add(new Field("content", feed.getContent(), Field.Store.YES, Field.Index.ANALYZED, Field.TermVector.WITH_POSITIONS_OFFSETS));
    writer.addDocument(doc);
  }

  public int indexFeed(int feedId) throws CorruptIndexException, IOException, InterruptedException, ClassNotFoundException, SQLException {
    setIndexWriter(isEmpty());
    Feed feed = find(feedId);
    if (feed != null) {
      checkFeedIndex(feed);
      indexFeedContent(feed);
    }
    int numIndexed = writer.numDocs();
    writer.optimize();
    writer.close();
    return numIndexed;
  }

  /**
   * 根据ID查找Feed
   * @param id
   * @return
   * @throws ClassNotFoundException
   * @throws SQLException
   */
  public Feed find(int id) throws ClassNotFoundException, SQLException {
    Connection connection = getFeedConnection();
    PreparedStatement stat = connection.prepareStatement("select * from feeds where id = ? ;");
    stat.setInt(1, id);
    ResultSet set = stat.executeQuery();
    Feed feed = null;
    if (set.next()) {
      feed = makeOfResultSet(set);
    }
    connection.close();
    return feed;
  }

  private void checkFeedIndex(Feed feed) throws IOException {
    if (!isEmpty()) {
      System.out.println(new StringBuffer("delete index feed ").append(feed.getId()));
      writer.deleteDocuments(new Term("id", feed.getId()));
    }
  }

  public int deleteIndex(int feedId) throws CorruptIndexException, LockObtainFailedException, IOException {
    writer = new IndexWriter(indexDir, new IKAnalyzer(), false, IndexWriter.MaxFieldLength.UNLIMITED);
    writer.setUseCompoundFile(false);// Setting to turn on usage of a compound file when on.
    writer.deleteDocuments(new Term("id", String.valueOf(feedId)));
    int numIndexed = writer.numDocs();
    System.out.println(new StringBuffer("delete index feed ").append(feedId));
    writer.optimize();
    writer.close();
    return numIndexed;
  }

  /**
   * 返回Feed的索引目录是否为空
   * @return
   */
  public boolean isEmpty() throws IOException {
    return indexDir.listAll().length == 0;
  }

  /**
   * 获取feed数据库的数据库链接
   * @return
   * @throws ClassNotFoundException
   * @throws SQLException
   */
  private Connection getFeedConnection() throws ClassNotFoundException, SQLException {
    Class.forName("com.mysql.jdbc.Driver");
    return DriverManager.getConnection(cf.getFeedDatabaseUrl(), cf.getDatabaseUserName(), cf.getDatabasePassword());
  }
}
