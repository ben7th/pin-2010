package luceneservice;

/**
 * 导图的封装类
 * 只用得到导图的id，content，title
 * @author Administrator
 */
public class Mindmap {

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
  public static void main(String[] args) throws ClassNotFoundException, SQLException {
    Mindmap m = Mindmap.find("8");
    System.out.println(m);
  }
   */
}
