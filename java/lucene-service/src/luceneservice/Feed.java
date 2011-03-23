/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package luceneservice;

/**
 * 封装Feed类，只使用到了id 和 content
 * @author Administrator
 */
public class Feed {

  private String id;        // feed的id
  private String content;   // feed的内容
  private String email;     // feed的创建者的email

  Feed(String id, String content, String email){
    this.id = id;
    this.content = content;
    this.email = email;
  }

  public String getContent(){
    // 数据库中的feed存在一些内容为null的情况
    if(content==null){
      return "";
    }
    return content;
  }

  public String getId(){
    return id;
  }

  public String getEmail(){
    return email;
  }
}
