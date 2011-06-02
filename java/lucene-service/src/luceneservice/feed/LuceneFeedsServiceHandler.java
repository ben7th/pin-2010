package luceneservice.feed;

import luceneservice.feed.search.FeedSearcher;
import luceneservice.feed.index.FeedIndexer;
import luceneservice.feed.search.FeedQueryOption;
import java.io.File;
import java.util.ArrayList;
import java.util.List;
import luceneservice.IkAnalyzerWord;
import org.apache.thrift.TException;

public class LuceneFeedsServiceHandler implements LuceneFeedsService.Iface {

  public FeedIndexer indexer;
  public FeedSearcher searcher;

  public LuceneFeedsServiceHandler(File index_dir_file) {
    this.indexer = new FeedIndexer(index_dir_file);
    this.searcher = new FeedSearcher(index_dir_file);
  }

  /**
   * 索引所有的feeds
   */
  public boolean index() throws TException {
    try {
      int size = this.indexer.indexAllFeeds();
      return size != 0;
    } catch (Exception ex) {
      ex.printStackTrace();
      return false;
    }
  }

  /**
   * 索引单个的feed
   */
  public boolean index_one_feed(int feed_id) throws TException {
    try {
      int size = this.indexer.indexFeed(feed_id);
      return size != 0;
    } catch (Exception ex) {
      ex.printStackTrace();
      return false;
    }
  }

  /**
   * 删除对某一个feed的索引
   */
  public boolean delete_index(int feed_id) throws TException {
    try {
      int size = this.indexer.deleteIndex(feed_id);
      return size != 0;
    } catch (Exception ex) {
      ex.printStackTrace();
      return false;
    }
  }

  // 以下为搜索
  //*********************************

  /**
   * 返回所有的搜索结果
   */
  public String search(String query) throws TException {
    try {
      FeedQueryOption query_option = new FeedQueryOption(query);
      return this.searcher.search(query_option);
    } catch (Exception ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  /**
   * 返回某一些搜索结果
   */
  public String search_page(String query, int start, int count) throws TException {
    try {
      FeedQueryOption query_option = new FeedQueryOption(query, start, count);
      return this.searcher.search(query_option);
    } catch (Exception ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  /**
   * 在某个用户的feeds中进行搜索
   */
  public String search_by_user(String query, String creator_id) throws TException {
    try {
      FeedQueryOption query_option = new FeedQueryOption(query, creator_id);
      return this.searcher.search(query_option);
    } catch (Exception ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  /**
   * 在某个用户的feeds中进行分页搜索
   */
  public String search_page_by_user(String query, int start, int count, String creator_id) throws TException {
    try {
      FeedQueryOption query_option = new FeedQueryOption(query, start, count, creator_id);
      return this.searcher.search(query_option);
    } catch (Exception ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  /**
   * 对一段文本进行分词，返回分词后的字符串数组
   */
  public List<String> parse_content(String content) throws TException {
    try {
      IkAnalyzerWord ika = new IkAnalyzerWord(content);
      return ika.getResult();
    } catch (Exception ex) {
      ex.printStackTrace();
      return new ArrayList<String>();
    }
  }
}