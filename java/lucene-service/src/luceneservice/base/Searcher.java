package luceneservice.base;

import java.io.File;

/**
 * 搜索基类
 */
public abstract class Searcher {

  public File index_dir_file;      // 索引路径

  public Searcher(File index_dir_file){
    try {
      this.index_dir_file = index_dir_file;
      makeSureIndexExist();
    } catch (Exception ex) {
      System.out.println("Index directory or Index files is not exist. Search failure");
    }
  }

  /**
   * 检测索引是否存在
   */
  public void makeSureIndexExist() throws Exception {
    if (!index_dir_file.exists() || !index_dir_file.isDirectory()) {
      throw new Exception(index_dir_file + "does not exist or is a directory");
    }
    if (index_dir_file.listFiles().length == 0) {
      throw new Exception(index_dir_file + "has none index files");
    }
  }
}
