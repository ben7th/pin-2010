/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package lucene;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import org.apache.lucene.queryParser.ParseException;
import org.apache.thrift.TException;

/**
 *
 * @author Administrator
 */
public class LuceneMindmapsServiceHandler implements LuceneMindmapsService.Iface {

  public static final String MINDMAP_INDEX_PATH = "/web/2010/lucene/mindmaps/index";

  /**
   * 初始化索引目录
   */
  public static void initIndexPath() {
    checkOrMkdir(MINDMAP_INDEX_PATH);
  }

  /**
   * 检查并文件是否存在，若不存在则创建之
   * @param filePath
   */
  public static void checkOrMkdir(String filePath) {
    File file = new File(filePath);
    if (!file.exists()) {
      file.mkdirs();
    }
  }

  public boolean index() throws TException {
    try {
      MindmapIndexer mi = new MindmapIndexer(MINDMAP_INDEX_PATH);
      int size = mi.indexAllMindmap();
      return size != 0;
    } catch (ClassNotFoundException ex) {
      return false;
    } catch (SQLException ex) {
      return false;
    } catch (IOException ex) {
      return false;
    }
  }

  public boolean index_one_mindmap(int mindmap_id) throws TException {
    try {
      MindmapIndexer mi = new MindmapIndexer(MINDMAP_INDEX_PATH);
      Mindmap mindmap = Mindmap.find(mindmap_id);
      int size = mi.indexMindmap(mindmap);
      return size != 0;
    } catch (ClassNotFoundException ex) {
      return false;
    } catch (SQLException ex) {
      return false;
    } catch (IOException ex) {
      return false;
    }
  }

  public boolean delete_index(int mindmap_id) throws TException {
    try {
      MindmapIndexer mi = new MindmapIndexer(MINDMAP_INDEX_PATH);
      int size = mi.deleteIndex(mindmap_id);
      return size != 0;
    } catch (IOException ex) {
      return false;
    }
  }

  public String search(String query) throws TException {
    try {
      Searcher s = new MindmapSearcher(MINDMAP_INDEX_PATH, query);
      String result = s.search(MindmapSearcher.SEARCH_FIELDS);
      return result;
    } catch (IOException ex) {
      ex.printStackTrace();
      return "error";
    } catch (ParseException ex) {
      ex.printStackTrace();
      return "error";
    } catch (Exception ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  public String search_page(String query, int start, int count) throws TException {
    try {
      Searcher s = new MindmapSearcher(MINDMAP_INDEX_PATH, query, start, count);
      String result = s.search(MindmapSearcher.SEARCH_FIELDS);
      return result;
    } catch (IOException ex) {
      return "error";
    } catch (ParseException ex) {
      return "error";
    } catch (Exception ex) {
      return "error";
    }
  }
}
