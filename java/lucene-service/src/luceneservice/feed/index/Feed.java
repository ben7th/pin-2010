/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package luceneservice.feed.index;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import luceneservice.Main;

/**
 * 封装Feed类，只封装了一部分字段，用于生成索引
 * @author Chengliwen
 * @author Lifei
 */
public class Feed {

  private int id;             // feed的id
  private String content;     // feed的内容
  private int creator_id;     // feed的创建者的creatorId
  private String detail;      // feed 的详细内容
  private String[] tag_strs;  // 关键字字符串数组，不考虑名称空间
  private boolean hidden;

  Feed(int id, String content, int creator_id, String detail, String[] tag_strs, boolean hidden) {
    this.id = id;
    this.content = content;
    this.creator_id = creator_id;
    this.detail = detail;
    this.tag_strs = tag_strs;
    this.hidden = hidden;
  }

  public String getContent() {
    // 数据库中的feed存在一些内容为null的情况
    if (content == null) {
      return "";
    }
    return content;
  }

  public int getId() {
    return id;
  }

  public String getIdStr(){
    return String.valueOf(getId());
  }

  public int getCreatorId() {
    return creator_id;
  }

  public String getCreatorIdStr(){
    return String.valueOf(getCreatorId());
  }

  public String getDetail() {
    if (detail == null) {
      return "";
    }
    return detail;
  }

  public String[] getTagStrs() {
    return tag_strs;
  }

  public boolean getHidden(){
    return hidden;
  }

  public boolean isHidden(){
    return getHidden();
  }

  /*get方法结束*/

  public static Feed find(int feed_id) {
    Connection connection = null;
    PreparedStatement statement = null;
    ResultSet set = null;
    Feed feed = null;
    
    try {
      connection = getConnection();
      statement = connection.prepareStatement("SELECT * FROM feeds WHERE id = ?");
      statement.setInt(1, feed_id);
      set = statement.executeQuery();
      if (set.first()) {
        feed = makeOfResultSet(set);
      }
      return feed;
    } catch (SQLException ex) {
      ex.printStackTrace();
      return feed;
    } finally {
      try {
        if (set != null) set.close();
        if (statement != null) statement.close();
        if (connection != null) connection.close();
      } catch (SQLException ex) {}
    }
  }

  public static Connection getConnection() throws SQLException {
    try {
      Class.forName("com.mysql.jdbc.Driver");
    } catch (ClassNotFoundException ex) {
      return null;
    }
    return DriverManager.getConnection(Main.config_file.getFeedDatabaseUrl(), Main.config_file.getDatabaseUserName(), Main.config_file.getDatabasePassword());
  }

  public static Feed makeOfResultSet(ResultSet set) throws SQLException {
    int feedId = set.getInt("id");
    String content = set.getString("content");
    int creatorId = set.getInt("creator_id");
    boolean hidden = set.getBoolean("hidden");

    Connection connection = getConnection();
    String detail = getFeedDetailById(feedId, connection);
    String[] tag_strs = getFeedTagStrsById(feedId, connection);
    Feed feed = new Feed(feedId, content, creatorId, detail, tag_strs, hidden);
    return feed;
  }

  // 查询正文
  private static String getFeedDetailById(int feed_id, Connection connection) {
    PreparedStatement stat = null;
    ResultSet set = null;
    
    try {
      stat = connection.prepareStatement("SELECT * FROM feed_details WHERE feed_id = ?");
      stat.setInt(1, feed_id);
      set = stat.executeQuery();

      if(set.first()){
        return set.getString("content");
      }else{
        return "";
      }
    } catch (SQLException ex) {
      ex.printStackTrace();
      return "";
    } finally {
      try {
        if (set != null) set.close();
        if (stat != null) stat.close();
      } catch (SQLException ex) {}
    }
  }

  // 查询tags 以及tags别名
  private static String[] getFeedTagStrsById(int feed_id, Connection connection) {
    PreparedStatement stat = null;
    ResultSet set = null;
    List<String> list = new ArrayList<String>();
    try {
      stat = connection.prepareStatement(
        "SELECT TN.name "+
        "FROM tag_another_names TN "+
        "WHERE TN.tag_id IN ( "+
          "SELECT T.id "+
          "FROM tags T "+
          "INNER JOIN feed_tags FT ON FT.tag_id = T.id "+
          "WHERE FT.feed_id = ? "+
        ") "+

        "UNION "+

        "SELECT T.name "+
        "FROM tags T "+
        "INNER JOIN feed_tags FT ON FT.tag_id = T.id "+
        "WHERE FT.feed_id = ? "
      );
      stat.setInt(1, feed_id);
      stat.setInt(2, feed_id);
      
      set = stat.executeQuery();
      while (set.next()) {
        list.add(set.getString("name"));
      }

      return list.toArray(new String[list.size()]);
    } catch (SQLException ex) {
      ex.printStackTrace();
      return null;
    } finally {
      try {
        if (set != null) set.close();
        if (stat != null) stat.close();
      } catch (SQLException ex) {
      }
    }
  }


  
/**

  public static void main(String[] args) throws IOException {
    Main.cf = new ConfigFile("development");

    Feed feed = Feed.find(1834);
    System.out.println(feed.getId());
    System.out.println(feed.getContent());
    System.out.println(feed.getCreatorId());
    System.out.println(feed.getDetail());
    String[] strs = feed.getTagStrs();
    for(int i=0;i<strs.length;i++){
      System.out.println(strs[i]);
    }
    System.out.println(feed.getHidden());

  }
 */
  
}
