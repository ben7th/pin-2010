package luceneservice.mindmap.index;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import luceneservice.base.Indexer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.Term;

/**
 * 导图索引
 * 注意：私有导图，不做索引
 * @author Administrator
 */
public class MindmapIndexer extends Indexer {
  
  public MindmapIndexer(File index_dir){
    super(index_dir);
  }

  /**
   * 公开方法：索引所有的导图
   */
  public int indexAllMindmap() throws ClassNotFoundException, SQLException, IOException, InterruptedException {
    Connection connection = null;
    PreparedStatement statement = null;
    ResultSet set = null;
    int i = 0;

    try {
      connection = Mindmap.getConnection();
      statement = connection.prepareStatement("SELECT * FROM mindmaps WHERE private = false");
      statement.setFetchSize(Integer.MIN_VALUE);
      set = statement.executeQuery();
      forceUnlockIndex();

      long begin = new Date().getTime();
      IndexWriter writer = getIndexWriter(true);
      while (set.next()) {
        Mindmap mindmap = Mindmap.makeOfResultset(set);
        indexMindmapContent(writer, mindmap);
        i++;
      }
      writer.optimize();
      writer.close();
      connection.close();
      long end = new Date().getTime();

      System.out.println(new StringBuffer("Good job and good luck OK ! indexed ").append(i).append(" mindmaps total cost ").append(end - begin).append(" millisecs."));
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

  /**
   * 公开方法：根据指定id 索引单个的导图
   */
  public int indexMindmap(int mindmap_id) throws IOException, ClassNotFoundException, SQLException, InterruptedException {
    IndexWriter writer = getIndexWriter(isIndexDirEmpty());
    Mindmap mindmap = Mindmap.find(mindmap_id);

    doDeleteMindmapIndex(writer, mindmap_id);
    if (!mindmap.isPrivate()) {
      indexMindmapContent(writer, mindmap);
    }

    int numIndexed = writer.numDocs();
    writer.optimize();
    writer.close();
    return numIndexed;
  }

  /**
   * 公开方法：根据指定id 删除单个导图的索引
   */
  public int deleteIndex(int mindmap_id) throws IOException, InterruptedException{
    IndexWriter writer = getIndexWriter(false);
    doDeleteMindmapIndex(writer, mindmap_id);
    
    int numIndexed = writer.numDocs();
    writer.optimize();
    writer.close();
    return numIndexed;
  }

  
  /**
   * 索引指定的一个导图
   */
  private void indexMindmapContent(IndexWriter writer, Mindmap mindmap) {
    try {
      System.out.println(new StringBuffer().append("indexing ").append(mindmap.getId()).append(" ").append(mindmap.getTitle()));

      Field field_id = new Field("id", mindmap.getIdStr(),
        Field.Store.YES,
        Field.Index.NOT_ANALYZED_NO_NORMS
      );

      Field field_user_id = new Field("user_id", mindmap.getUserIdStr(),
        Field.Store.YES,
        Field.Index.NOT_ANALYZED_NO_NORMS
      );

      Field field_title = new Field("title", mindmap.getTitle(),
        Field.Store.YES,
        Field.Index.ANALYZED,
        Field.TermVector.WITH_POSITIONS_OFFSETS
      );

      Field field_content = new Field("content", mindmap.getContent(),
        Field.Store.YES,
        Field.Index.ANALYZED,
        Field.TermVector.WITH_POSITIONS_OFFSETS
      );

      field_content.setBoost(2.0f);

      Document doc = new Document();
      doc.add(field_id);
      doc.add(field_user_id);
      doc.add(field_title);
      doc.add(field_content);
      writer.addDocument(doc);
    } catch (CorruptIndexException ex) {
      System.out.println("index failure");
    } catch (IOException ex) {
      System.out.println("index failure");
    }
  }

  /**
   * 删除指定的一个导图id对应的导图索引
   */
  private void doDeleteMindmapIndex(IndexWriter writer, int mindmap_id) {
    try {
      System.out.println(new StringBuffer("delete index ").append(mindmap_id));
      writer.deleteDocuments(new Term("id", String.valueOf(mindmap_id)));
    }
    catch (CorruptIndexException ex) {
      System.out.println("delete index failure");
    }
    catch (IOException ex) {
      System.out.println("delete index failure");
    }
  }

}