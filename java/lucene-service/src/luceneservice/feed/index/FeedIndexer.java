package luceneservice.feed.index;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;
import luceneservice.base.Indexer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.Term;
import org.apache.lucene.store.LockObtainFailedException;

/**
 * Feed的索引操作
 * @author Administrator
 */
public class FeedIndexer extends Indexer {

  public FeedIndexer(File index_dir){
    super(index_dir);
  }

  /**
   * 公开方法：索引所有的主题
   */
  public int indexAllFeeds() throws ClassNotFoundException, IOException, CorruptIndexException, InterruptedException {
    Connection connection = null;
    PreparedStatement statement = null;
    ResultSet set = null;
    int i = 0;
    
    try {
      connection = Feed.getConnection();
      statement = connection.prepareStatement("SELECT * FROM feeds WHERE hidden = false");
      statement.setFetchSize(Integer.MIN_VALUE);
      set = statement.executeQuery();
      forceUnlockIndex();

      long begin = new Date().getTime();
      IndexWriter writer = getIndexWriter(true);
      while (set.next()) {
        Feed feed = Feed.makeOfResultSet(set);
        indexFeedContent(writer, feed);
        i++;
      }
      writer.optimize();
      writer.close();
      long end = new Date().getTime();

      System.out.println(new StringBuffer("Good job and good luck OK ! indexed ").append(i).append(" feeds total cost ").append(end - begin).append(" millisecs."));
      return i;

    } catch (SQLException ex) {
      ex.printStackTrace();
      return i;
    }finally{
      try {
        if (set != null) set.close();
        if (statement != null) statement.close();
        if (connection != null) connection.close();
      } catch (SQLException ex) {}
    }
  }

  /*
   * 公开方法：根据传入的feed_id索引指定的一个feed
   */
  public int indexFeed(int feed_id) throws CorruptIndexException, IOException, InterruptedException, ClassNotFoundException, SQLException {
    IndexWriter writer = getIndexWriter(isIndexDirEmpty());
    Feed feed = Feed.find(feed_id);

    doDeleteFeedIndex(writer, feed.getId());
    if(!feed.isHidden()){
      indexFeedContent(writer, feed);
    }
    
    int numIndexed = writer.numDocs();
    writer.optimize();
    writer.close();
    return numIndexed;
  }

  /*
   * 根据传入的feed_id删除指定的一个feed
   */
  public int deleteIndex(int feed_id) throws CorruptIndexException, LockObtainFailedException, IOException, InterruptedException {
    IndexWriter writer = getIndexWriter(false);
    doDeleteFeedIndex(writer, feed_id);
    
    int numIndexed = writer.numDocs();
    writer.optimize();
    writer.close();
    return numIndexed;
  }

  
  /**
   * 索引指定的一个feed
   */
  private void indexFeedContent(IndexWriter writer, Feed feed) throws CorruptIndexException, IOException {
    System.out.println(new StringBuffer().append("indexing feed ").append(feed.getId()));
    
    Field field_id = new Field("id", feed.getIdStr(), 
      Field.Store.YES, 
      Field.Index.NOT_ANALYZED_NO_NORMS
    );

    Field field_creator_id = new Field("creator_id", feed.getCreatorIdStr(),
      Field.Store.YES,
      Field.Index.NOT_ANALYZED_NO_NORMS
    );

    Field field_content = new Field("content", feed.getContent(),
      Field.Store.YES,
      Field.Index.ANALYZED,
      Field.TermVector.WITH_POSITIONS_OFFSETS
    );
    field_content.setBoost(2.0f);

    Field field_detail = new Field("detail", feed.getDetail(),
      Field.Store.YES,
      Field.Index.ANALYZED,
      Field.TermVector.WITH_POSITIONS_OFFSETS
    );


    Document doc = new Document();
    doc.add(field_id);
    doc.add(field_creator_id);
    doc.add(field_content);
    doc.add(field_detail);

    String[] tagStrs = feed.getTagStrs();
    
    for(int i=0;i<tagStrs.length;i++){
      Field field_tag = new Field("tag", tagStrs[i],
        Field.Store.YES,
        Field.Index.ANALYZED
      );
      field_tag.setBoost(3.0f);
      doc.add(field_tag);
    }

    writer.addDocument(doc);
  }

  /*
   * 执行删除某一条feed索引的操作
   */
  private void doDeleteFeedIndex(IndexWriter writer, int feed_id) {
    try {
      System.out.println("delete index feed " + feed_id);
      writer.deleteDocuments(new Term("id", String.valueOf(feed_id)));
    }
    catch (CorruptIndexException ex) {
      System.out.println("delete index failure");
    }
    catch (IOException ex) {
      System.out.println("delete index failure");
    }
  }

}