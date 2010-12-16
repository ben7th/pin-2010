package lucene;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import org.apache.thrift.TException;

/**
 * 实现Lucene服务接口的类
 * @author Administrator
 */
public class LuceneNotesServiceHandler implements LuceneNotesService.Iface {

  public static final String NOTE_FULL_INDEX_PATH = "/web/2010/lucene/notes/full_index";
  public static final String NOTE_NEWEST_INDEX_PATH = "/web/2010/lucene/notes/newest_index";
  public static final String DATA_PATH = "/root/mindpin_base/note_repo/notes";
  public static final String NOTE_NEWEST_TYPE = "NOTE_NEWEST";
  public static final String NOTE_FULL_TYPE = "NOTE_FULL";

  /**
   * 初始化索引目录
   */
  public static void initIndexPath() {
    checkOrMkdir(NOTE_FULL_INDEX_PATH);
    checkOrMkdir(NOTE_NEWEST_INDEX_PATH);
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

  /**
   * 实现索引操作的方法
   * @param index_path
   * @return
   * @throws TException
   */
  public boolean index(String index_path) throws TException {
    return index_method(index_path, null);
  }

  /**
   * 带commit_id 的数据建立索引
   * @param index_path
   * @param commit_id
   * @return
   * @throws TException
   */
  public boolean index_with_commit_id(String index_path, String commit_id) throws TException {
    return index_method(index_path, commit_id);
  }

  private boolean index_method(String index_path, String commit_id) {
    try {
      String[] strs = index_path.split(";");
      long start = new Date().getTime();
      for (String dir : strs) {
        System.out.println(dir);
        NoteIndexer full_indexer = new NoteIndexer(NOTE_FULL_INDEX_PATH, dir, commit_id, NOTE_FULL_TYPE);
        full_indexer.index();
        NoteIndexer newest_indexer = new NoteIndexer(NOTE_NEWEST_INDEX_PATH, dir, commit_id, NOTE_NEWEST_TYPE);
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
      NoteIndexer full_indexer = new NoteIndexer(NOTE_FULL_INDEX_PATH, delete_path);
      NoteIndexer new_indexer = new NoteIndexer(NOTE_NEWEST_INDEX_PATH, delete_path);
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
      return "";
    }
  }

  /**
   * 搜索所有notes的索引
   * @param query
   * @return
   * @throws TException
   */
  public String search_full(String query) throws TException {
    return search(NOTE_FULL_INDEX_PATH, query);
  }

  /**
   * 搜索最新的notes的索引
   * @param query
   * @return
   * @throws TException
   */
  public String search_newest(String query) throws TException {
    return search(NOTE_NEWEST_INDEX_PATH, query);
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
      return "";
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
    return search_page(NOTE_FULL_INDEX_PATH, query, start, count);
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
    return search_page(NOTE_NEWEST_INDEX_PATH, query, start, count);
  }
}
