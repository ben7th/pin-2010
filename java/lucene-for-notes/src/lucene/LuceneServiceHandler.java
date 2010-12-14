/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package lucene;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import org.apache.thrift.TException;

/**
 *
 * @author Administrator
 */
public class LuceneServiceHandler implements LuceneService.Iface {

  public static String FULL_INDEX_PATH = "/web/2010/lucene/notes/index";
  public static String NEWEST_INDEX_PATH = "/web/2010/lucene/notes/new_index";
  public static String DATA_PATH = "/root/mindpin_base/note_repo/notes";

  public static void initIndexPath() {
    File file = new File(FULL_INDEX_PATH);
    if (!file.exists()) {
      file.mkdirs();
    }
    File newfile = new File(NEWEST_INDEX_PATH);
    if (!newfile.exists()) {
      newfile.mkdirs();
    }
  }

  // 实现索引操作的方法
  public boolean index(String index_path) throws TException {
    return index_method(index_path, null);
  }

  public boolean index_with_commit_id(String index_path, String commit_id) throws TException {
    return index_method(index_path, commit_id);
  }

  private boolean index_method(String index_path, String commit_id) {
    try {
      String[] strs = index_path.split(";");
      long start = new Date().getTime();
      for (String dir : strs) {
        System.out.println(dir);
        NoteIndexer indexer = new NoteIndexer(dir, FULL_INDEX_PATH, NEWEST_INDEX_PATH, commit_id);
        indexer.index();
        System.out.println(dir + " 索引结束");
      }
      long end = new Date().getTime();
      System.out.println("Indexing " + (strs.length) + " files took " + (end - start) + "milliseconds");
      return true;
    } catch (IOException iOException) {
      iOException.printStackTrace();
      return false;
    }
  }

  public String search_with_commit_id(String query, String commit_id) throws TException {
    throw new UnsupportedOperationException("Not supported yet.");
  }

  public boolean delete_index(String delete_path) throws TException {
    try {
      NoteIndexer indexer = new NoteIndexer(delete_path, FULL_INDEX_PATH, NEWEST_INDEX_PATH,null);
      return indexer.deleteIndex(delete_path);
    } catch (IOException ex) {
      ex.printStackTrace();
      return false;
    }
  }

  // 实现整体搜索操作的方法
  private String search(String indexPathTmp, String query) throws TException {
    try {
      NoteSearcher s = new NoteSearcher(indexPathTmp, query);
      return s.search();
    } catch (Exception e) {
      e.printStackTrace();
      return "";
    }
  }

  // 搜索所有notes的索引
  public String search_full(String query) throws TException {
    return search(FULL_INDEX_PATH, query);
  }

  // 搜索最新的notes的索引
  public String search_newest(String query) throws TException {
    return search(NEWEST_INDEX_PATH, query);
  }

  //分页搜索的实现
  private String search_page(String indexPathTmp,String query, int start, int count){
    try {
      NoteSearcher s = new NoteSearcher(indexPathTmp, query,start,count);
      return s.search();
    } catch (Exception e) {
      e.printStackTrace();
      return "";
    }
  }

  public String search_page_full(String query, int start, int count) throws TException {
    return search_page(FULL_INDEX_PATH,query,start,count);
  }

  public String search_page_newest(String query, int start, int count) throws TException {
    return search_page(NEWEST_INDEX_PATH,query,start,count);
  }
}
