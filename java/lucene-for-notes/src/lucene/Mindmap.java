package lucene;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * 导图的封装类
 * 只用得到导图的id，content，title
 * @author Administrator
 */
public class Mindmap {

  private static Connection connection;   //查找导图的数据链接
  private String id;                      //导图id
  private String content;                 //导图内容
  private String title;                   //导图标题

  public String getContent() {
    return content;
  }

  public String getId() {
    return id;
  }

  public String getTitle() {
    return title;
  }

  Mindmap(String id, String title, String content) {
    this.id = id;
    this.content = content;
    this.title = title;
  }

  /**
   * 根据id找到mindmap
   * @param id
   * @return
   * @throws ClassNotFoundException
   * @throws SQLException
   */
  public static Mindmap find(int id) throws ClassNotFoundException, SQLException {
    connection = DBConnection.getConnection();
    PreparedStatement stat = connection.prepareStatement("select * from mindmaps where id = ? ;");
    stat.setInt(1, id);
    ResultSet set = stat.executeQuery();
    Mindmap mp = null;
    if (set.next()) {
      mp = new Mindmap(set.getString("id"), set.getString("title"), set.getString("content"));
    }
    connection.close();
    return mp;
  }

  /**
  public static void main(String[] args) throws ClassNotFoundException, SQLException {
    Mindmap m = Mindmap.find("8");
    System.out.println(m);
  }
   */
}
