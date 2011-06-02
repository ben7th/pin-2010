package luceneservice.mindmap;

import luceneservice.mindmap.search.MindmapSearcher;
import luceneservice.mindmap.index.MindmapIndexer;
import luceneservice.mindmap.search.MindmapQueryOption;
import java.io.File;
import java.util.ArrayList;
import java.util.List;
import luceneservice.IkAnalyzerWord;
import org.apache.thrift.TException;

public class LuceneMindmapsServiceHandler implements LuceneMindmapsService.Iface {

  public MindmapIndexer indexer;
  public MindmapSearcher searcher;

  public LuceneMindmapsServiceHandler(File index_dir_file){
    this.indexer = new MindmapIndexer(index_dir_file);
    this.searcher = new MindmapSearcher(index_dir_file);
  }

  /**
   * 索引所有的导图
   */
  public boolean index() throws TException {
    try {
      int size = this.indexer.indexAllMindmap();
      return size != 0;
    } catch (Exception ex) {
      ex.printStackTrace();
      return false;
    }
  }

  /**
   * 索引单个导图
   */
  public boolean index_one_mindmap(int mindmap_id) throws TException {
    try {
      int size = this.indexer.indexMindmap(mindmap_id);
      return size != 0;
    } catch (Exception ex) {
      ex.printStackTrace();
      return false;
    }
  }

  /**
   * 删除某一个导图的索引
   */
  public boolean delete_index(int mindmap_id) throws TException {
    try {
      int size = this.indexer.deleteIndex(mindmap_id);
      return size != 0;
    } catch (Exception ex) {
      ex.printStackTrace();
      return false;
    }
  }

  // 以下为搜索
  //*********************************

  /**
   * 搜索，获取全部结果
   */
  public String search(String query) throws TException {
    try {
      MindmapQueryOption query_option = new MindmapQueryOption(query);
      return this.searcher.search(query_option);
    } catch (Exception ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  /**
   * 搜索，获取部分结果
   */
  public String search_page(String query, int start, int count) throws TException {
    try {
      MindmapQueryOption query_option = new MindmapQueryOption(query, start, count);
      return this.searcher.search(query_option);
    } catch (Exception ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  /**
   * 根据user_id搜索，获取全部结果
   */
  public String search_by_user(String query, int user_id) throws TException {
    try {
      MindmapQueryOption query_option = new MindmapQueryOption(query, user_id);
      return this.searcher.search(query_option);
    } catch (Exception ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  /**
   * 根据user_id搜索，获取部分结果
   */
  public String search_page_by_user(String query, int start, int count, int user_id) throws TException {
    try {
      MindmapQueryOption query_option = new MindmapQueryOption(query, start, count, user_id);
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