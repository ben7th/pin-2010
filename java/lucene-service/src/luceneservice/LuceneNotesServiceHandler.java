package luceneservice;

import java.io.IOException;
import java.util.Date;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.thrift.TException;

/**
 * 实现Lucene服务接口的类
 * @author Administrator
 */
public class LuceneNotesServiceHandler implements LuceneNotesService.Iface {

  // Note的索引类型
  public static final String NOTE_NEWEST_TYPE = "NOTE_NEWEST";
  public static final String NOTE_FULL_TYPE = "NOTE_FULL";
  private String fullIndexPath;
  private String newestIndexPath;

  public LuceneNotesServiceHandler() {
  }

  public LuceneNotesServiceHandler(ConfigFile cf) {
    this.fullIndexPath = cf.getNoteFullIndexPath();
    this.newestIndexPath = cf.getNoteNewestIndexPath();
  }

  /**
   * 实现索引操作的方法
   * @param index_path
   * @return
   * @throws TException
   */
  public boolean index(String index_path) throws TException {
    try {
      return index_method(index_path, null);
    } catch (CorruptIndexException ex) {
      ex.printStackTrace();
      return false;
    } catch (InterruptedException ex) {
      ex.printStackTrace();
      return false;
    }
  }

  /**
   * 带commit_id 的数据建立索引
   * @param index_path
   * @param commit_id
   * @return
   * @throws TException
   */
  public boolean index_with_commit_id(String index_path, String commit_id) throws TException {
    try {
      return index_method(index_path, commit_id);
    } catch (CorruptIndexException ex) {
      ex.printStackTrace();
      return false;
    } catch (InterruptedException ex) {
      ex.printStackTrace();
      return false;
    }
  }

  private boolean index_method(String index_path, String commit_id) throws CorruptIndexException, InterruptedException {
    try {
      String[] strs = index_path.split(";");
      long start = new Date().getTime();
      for (String dir : strs) {
        System.out.println(dir);
        NoteIndexer full_indexer = new NoteIndexer(fullIndexPath, dir, commit_id, NOTE_FULL_TYPE);
        full_indexer.index();
        NoteIndexer newest_indexer = new NoteIndexer(newestIndexPath, dir, commit_id, NOTE_NEWEST_TYPE);
        newest_indexer.index();
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

  /**
   * 根据commit_id来索引文件，暂未实现
   * @param query
   * @param commit_id
   * @return
   * @throws TException
   */
  public String search_with_commit_id(String query, String commit_id) throws TException {
    throw new UnsupportedOperationException("Not supported yet.");
  }

  public boolean delete_index(String delete_path) throws TException {
    try {
      NoteIndexer full_indexer = new NoteIndexer(fullIndexPath, delete_path);
      NoteIndexer new_indexer = new NoteIndexer(newestIndexPath, delete_path);
      boolean full = full_indexer.deleteIndex();
      boolean newst = new_indexer.deleteIndex();
      return full && newst;
    } catch (IOException ex) {
      ex.printStackTrace();
      return false;
    }
  }

  /**
   * 搜索的操作方法
   * @param indexPathTmp
   * @param query
   * @return
   * @throws TException
   */
  private String search(String indexPathTmp, String query) throws TException {
    try {
      Searcher s = new NoteSearcher(indexPathTmp, query);
      return s.search(NoteSearcher.SEARCH_FIELDS);
    } catch (Exception e) {
      e.printStackTrace();
      return "error";
    }
  }

  /**
   * 搜索所有notes的索引
   * @param query
   * @return
   * @throws TException
   */
  public String search_full(String query) {
    try {
      return search(fullIndexPath, query);
    } catch (TException ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  /**
   * 搜索最新的notes的索引
   * @param query
   * @return
   * @throws TException
   */
  public String search_newest(String query) {
    try {
      return search(newestIndexPath, query);
    } catch (TException ex) {
      ex.printStackTrace();
      return "error";
    }
  }

  /**
   * 分页搜索的实现
   * @param indexPathTmp
   * @param query
   * @param start
   * @param count
   * @return
   */
  private String search_page(String indexPathTmp, String query, int start, int count) {
    try {
      Searcher s = new NoteSearcher(indexPathTmp, query, start, count);
      return s.search(NoteSearcher.SEARCH_FIELDS);
    } catch (Exception e) {
      e.printStackTrace();
      return "error";
    }
  }

  /**
   * 所有note的分页索引
   * @param query
   * @param start
   * @param count
   * @return
   * @throws TException
   */
  public String search_page_full(String query, int start, int count) throws TException {
    return search_page(fullIndexPath, query, start, count);
  }

  /**
   * 最新note分页搜索的实现
   * @param query
   * @param start
   * @param count
   * @return
   * @throws TException
   */
  public String search_page_newest(String query, int start, int count) throws TException {
    return search_page(newestIndexPath, query, start, count);
  }
}
