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

  private static String INDEX_PATH = "/web/2010/lucene/notes/index";
  public static void initIndexPath(){
    File file = new File(INDEX_PATH);
    if(!file.exists()){
      file.mkdirs();
    };
  } 
  // 实现索引操作的方法
  public boolean index(String index_path) throws TException {
    try {
      String[] strs = index_path.split(";");
      long start = new Date().getTime();
      for (String dir : strs) {
        System.out.println(dir);
        Indexer indexer = new Indexer(dir, INDEX_PATH);
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

  // 实现搜索操作的方法
  public String search(String query) throws TException {
    try {
      Searcher s = new Searcher(INDEX_PATH, query);
      return s.search();
    } catch (Exception e) {
      e.printStackTrace();
      return "";
    }
  }
}
