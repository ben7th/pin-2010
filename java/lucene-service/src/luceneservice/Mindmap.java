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
  private String userId;                  //导图作者的ID
  private String privated;                //导图是否私有

  Mindmap(String id, String title, String content, String userId, String privated) {
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

  public String getId() {
    return id;
  }

  public String getTitle() {
    return title;
  }

  public String getUserId() {
    return userId;
  }

  public String getPrivated(){
    return privated;
  }

  public boolean isPrivate(){
    if(privated == null){
      return false;
    }
    return privated.equals("1");
  }

  /**
  public static void main(String[] args) throws ClassNotFoundException, SQLException {
  Mindmap m = Mindmap.find("8");
  System.out.println(m);
  }
   */
}
