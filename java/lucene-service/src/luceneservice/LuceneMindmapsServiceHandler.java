package luceneservice;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.lucene.queryParser.ParseException;
import org.apache.thrift.TException;

/**
 *
 * @author Administrator
 */
public class LuceneMindmapsServiceHandler implements LuceneMindmapsService.Iface {

  private String indexPath;
  private ConfigFile cf;

  public LuceneMindmapsServiceHandler() {
  }

  public LuceneMindmapsServiceHandler(ConfigFile cf) {
    this.indexPath = cf.getMindmapIndexPath();
    this.cf = cf;
  }

  /**
   * 索引所有的导图
   * @return
   * @throws TException
   */
  public boolean index() throws TException {
    try {
      MindmapIndexer mi = new MindmapIndexer(cf);
      int size = mi.indexAllMindmap();
      return size != 0;
    } catch (Exception ex) {
      ex.printStackTrace();
      return false;
    }
  }

  /**
   * 索引单个导图
   * @param mindmap_id
   * @return
   * @throws TException
   */
  public boolean index_one_mindmap(int mindmap_id) throws TException {
    try {
      MindmapIndexer mi = new MindmapIndexer(cf);
      int size = mi.indexMindmap(mindmap_id);
      return size != 0;
    } catch (Exception ex) {
      ex.printStackTrace();
      return false;
    }
  }

  /**
   * 删除某一个导图的索引
   * @param mindmap_id
   * @return
   * @throws TException
   */
  public boolean delete_index(int mindmap_id) throws TException {
    try {
      MindmapIndexer mi = new MindmapIndexer(cf);
      int size = mi.deleteIndex(mindmap_id);
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
      Searcher s = new MindmapSearcher(indexPath, query);
      String result = s.search(MindmapSearcher.SEARCH_FIELDS);
      return result;
    } catch (Exception ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  /**
   * 返回搜索的某几个结果
   * @param query
   * @param start
   * @param count
   * @return
   * @throws TException
   */
  public String search_page(String query, int start, int count) throws TException {
    try {
      Searcher s = new MindmapSearcher(indexPath, query, start, count);
      String result = s.search(MindmapSearcher.SEARCH_FIELDS);
      return result;
    } catch (Exception ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  /**
   * 给你一段文本，返回一分词后的一个数组 
   * @param content
   * @return
   * @throws TException
   */
  public List<String> parse_content(String content) throws TException {
    try {
      IkAnalyzerWord ika = new IkAnalyzerWord(content);
      return ika.getResult();
    } catch (IOException ex) {
      ex.printStackTrace();
      return new ArrayList<String>();
    }
  }

  
}
