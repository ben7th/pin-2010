package luceneservice.mindmap.index;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import luceneservice.Main;
import luceneservice.base.ConfigFile;

/**
 * 导图的封装类
 * 只用得到导图的id，content，title
 * @author Administrator
 */
public class Mindmap {

  private int id;                      //导图id
  private String content;              //导图内容
  private String title;                //导图标题
  private int userId;                  //导图作者的ID
  private boolean privated;            //导图是否私有

  Mindmap(int id, String title, String content, int userId, boolean privated) {
    this.id = id;
    this.content = content;
    this.title = title;
    this.userId = userId;
    this.privated = privated;
  }

  public String getContent() {
    // 个别导图有内容是null的情况
    if (content == null) {
      return "";
    }
    return content;
  }

  public int getId() {
    return id;
  }

  public String getIdStr() {
    return String.valueOf(id);
  }

  public String getTitle() {
    return title;
  }

  public int getUserId() {
    return userId;
  }

  public String getUserIdStr() {
    return String.valueOf(userId);
  }

  public boolean getPrivated(){
    return privated;
  }

  public boolean isPrivate(){
    return getPrivated();
  }

  /**
   * 根据id找到mindmap
   * @param id
   * @return
   * @throws ClassNotFoundException
   * @throws SQLException
   */
  public static Mindmap find(int id) throws ClassNotFoundException, SQLException {
    Connection connection = getConnection();
    PreparedStatement stat = connection.prepareStatement("SELECT * FROM mindmaps WHERE id = ?");
    stat.setInt(1, id);
    ResultSet set = stat.executeQuery();
    Mindmap mp = null;
    if (set.next()) {
      mp = makeOfResultset(set);
    }
    connection.close();
    return mp;
  }

  /*
   * 根据查询结果构造实例
   */
  public static Mindmap makeOfResultset(ResultSet set) throws SQLException {
    Mindmap mindmap = new Mindmap(
      set.getInt("id"),
      set.getString("title"),
      set.getString("content"),
      set.getInt("user_id"),
      set.getBoolean("private")
    );
    return mindmap;
  }
  
  /**
   * 返回mysql数据库连接实例
   */
  public static Connection getConnection() throws ClassNotFoundException, SQLException {
    Class.forName("com.mysql.jdbc.Driver");
    
    ConfigFile config_file = Main.config_file;

    return DriverManager.getConnection(
      config_file.getMindmapDatabaseUrl(),
      config_file.getDatabaseUserName(),
      config_file.getDatabasePassword()
    );
  }

  /**
  public static void main(String[] args) throws ClassNotFoundException, SQLException {
  Mindmap m = Mindmap.find("8");
  System.out.println(m);
  }
   */
}
