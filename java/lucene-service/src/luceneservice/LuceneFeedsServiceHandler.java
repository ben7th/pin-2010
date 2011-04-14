package luceneservice;

import java.util.ArrayList;
import java.util.List;
import org.apache.thrift.TException;

/**
 * feed的对外接口
 * @author Administrator
 */
public class LuceneFeedsServiceHandler implements LuceneFeedsService.Iface {

  private String indexPath;
  private ConfigFile cf;

  LuceneFeedsServiceHandler() {
  }

  LuceneFeedsServiceHandler(ConfigFile cf) {
    this.indexPath = cf.getFeedIndexPath();
    this.cf = cf;
  }

  /**
   * 索引所有的feeds
   * @return
   * @throws TException
   */
  public boolean index() throws TException {
    try {
      FeedIndexer fi = new FeedIndexer(cf);
      int size = fi.indexAllFeeds();
      return size != 0;
    } catch (Exception ex) {
      ex.printStackTrace();
      return false;
    }
  }

  /**
   * 索引单个的feed
   * @param feed_id
   * @return
   * @throws TException
   */
  public boolean index_one_feed(int feed_id) throws TException {
    try {
      FeedIndexer fi = new FeedIndexer(cf);
      int size = fi.indexFeed(feed_id);
      return size != 0;
    } catch (Exception ex) {
      ex.printStackTrace();
      return false;
    }
  }

  /**
   * 删除对某一个feed的索引
   * @param feed_id
   * @return
   * @throws TException
   */
  public boolean delete_index(int feed_id) throws TException {
    try {
      FeedIndexer fi = new FeedIndexer(cf);
      int size = fi.deleteIndex(feed_id);
      return size != 0;
    } catch (Exception ex) {
      ex.printStackTrace();
      return false;
    }
  }

  /**
   * 返回所有的搜索结果
   * @param query
   * @return
   * @throws TException
   */
  public String search(String query) throws TException {
    try {
      Searcher s = new FeedSearcher(indexPath, query);
      String result = s.search(FeedSearcher.SEARCH_FIELDS);
      return result;
    } catch (Exception ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  /**
   * 返回某一些搜索结果
   * @param query
   * @param start
   * @param count
   * @return
   * @throws TException
   */
  public String search_page(String query, int start, int count) throws TException {
    try {
      Searcher s = new FeedSearcher(indexPath, query, start, count);
      String result = s.search(FeedSearcher.SEARCH_FIELDS);
      return result;
    } catch (Exception ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  public List<String> parse_content(String content) throws TException {
    try {
      IkAnalyzerWord ika = new IkAnalyzerWord(content);
      return ika.getResult();
    } catch (Exception ex) {
      ex.printStackTrace();
      return new ArrayList<String>();
    }
  }

  /**
   * 在某个用户的feeds中进行搜索
   * @param query
   * @param creator_id
   * @return
   * @throws TException
   */
  public String search_by_user(String query, String creator_id) throws TException {
    try {
      Searcher s = new FeedSearcher(indexPath, query);
      String result = s.searchFeedsByUserCreatorId(FeedSearcher.SEARCH_FIELDS, creator_id);
      return result;
    } catch (Exception ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  /**
   * 在某个用户的feeds中进行分页查找
   * @param query
   * @param start
   * @param count
   * @param email
   * @return
   * @throws TException
   */
  public String search_page_by_user(String query, int start, int count, String creator_id) throws TException {
    try {
      Searcher s = new FeedSearcher(indexPath, query, start, count);
      String result = s.searchFeedsByUserCreatorId(FeedSearcher.SEARCH_FIELDS,creator_id);
      return result;
    } catch (Exception ex) {
      ex.printStackTrace();
      return "error";
    }
  }
}