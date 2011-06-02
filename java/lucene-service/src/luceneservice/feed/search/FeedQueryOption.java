package luceneservice.feed.search;

import luceneservice.base.QueryOption;

public class FeedQueryOption extends QueryOption {

  public String creator_id_str;

  public FeedQueryOption(String query_str){
    super(query_str);
  }

  public FeedQueryOption(String query_str, int start, int count){
    super(query_str, start, count);
  }

  public FeedQueryOption(String query_str, String creator_id){
    super(query_str);
    this.creator_id_str = String.valueOf(creator_id);
  }

  public FeedQueryOption(String query_str, int start, int count, String creator_id){
    super(query_str, start, count);
    this.creator_id_str = String.valueOf(creator_id);
  }
}