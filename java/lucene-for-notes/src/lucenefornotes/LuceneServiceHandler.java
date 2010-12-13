/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package lucenefornotes;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import org.apache.thrift.TException;

/**
 *
 * @author Administrator
 */
public class LuceneServiceHandler implements LuceneService.Iface {

  public static String INDEX_PATH = "/web/2010/lucene/notes/index";
  public static String NEW_INDEX_PATH = "/web/2010/lucene/notes/new_index";
  public static String DATA_PATH = "/root/mindpin_base/note_repo/notes";

  public static void initIndexPath() {
    File file = new File(INDEX_PATH);
    if (!file.exists()) {
      file.mkdirs();
    }
    File newfile = new File(NEW_INDEX_PATH);
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
        Indexer indexer = new Indexer(dir, INDEX_PATH, NEW_INDEX_PATH, commit_id);
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
      Indexer indexer = new Indexer(delete_path, INDEX_PATH, NEW_INDEX_PATH,null);
      return indexer.deleteIndex(delete_path);
    } catch (IOException ex) {
      ex.printStackTrace();
      return false;
    }
  }

  public String full_search(String query) throws TException {
    return search(INDEX_PATH, query);
  }

  public String new_search(String query) throws TException {
    return search(NEW_INDEX_PATH, query);
  }

  // 实现搜索操作的方法
  private String search(String indexPathTmp, String query) throws TException {
    try {
      Searcher s = new Searcher(indexPathTmp, query);
      return s.search();
    } catch (Exception e) {
      e.printStackTrace();
      return "";
    }
  }
}
