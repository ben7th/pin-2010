package lucene;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author Administrator
 */
public class DBConnection {

  /**
   * 返回mysql数据库 链接 的类
   * @return
   * @throws ClassNotFoundException
   * @throws SQLException
   */
  public static Connection getConnection() throws ClassNotFoundException, SQLException {
    Class.forName("com.mysql.jdbc.Driver");
    return DriverManager.getConnection("jdbc:mysql://192.168.1.8:3306/pin-mindmap-editor-development", "root", "root");
  }

  /**
  public static void main(String[] args) throws ClassNotFoundException, SQLException {
    Connection con = getConnection();
    if (con != null) {
    System.out.println(2);
      Statement sta = con.createStatement();
      ResultSet rst = sta.executeQuery("select * from mindmaps");
      while (rst.next()) {
        System.out.println(rst.getString("id"));
        System.out.println(rst.getString("title"));
        System.out.println(rst.getString("content"));
      }
    }
  }
   */
  
}
