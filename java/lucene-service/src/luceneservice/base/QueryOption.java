/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package luceneservice.base;

/**
 * 查询参数包装类
 */
public abstract class QueryOption {
  public String query_str;
  public int start = -1;
  public int count = -1;

  public QueryOption(String query_str){
    this.query_str = query_str;
  }

  public QueryOption(String query_str, int start, int count){
    this.query_str = query_str;
    this.start = start;
    this.count = count;
  }
}
