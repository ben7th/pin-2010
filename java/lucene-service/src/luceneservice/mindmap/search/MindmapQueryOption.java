package luceneservice.mindmap.search;

import luceneservice.base.QueryOption;

public class MindmapQueryOption extends QueryOption {

  public String user_id_str;

  public MindmapQueryOption(String query_str){
    super(query_str);
  }

  public MindmapQueryOption(String query_str, int start, int count){
    super(query_str, start, count);
  }

  public MindmapQueryOption(String query_str, int user_id){
    super(query_str);
    this.user_id_str = String.valueOf(user_id);
  }

  public MindmapQueryOption(String query_str, int start, int count, int user_id){
    super(query_str, start, count);
    this.user_id_str = String.valueOf(user_id);
  }
}