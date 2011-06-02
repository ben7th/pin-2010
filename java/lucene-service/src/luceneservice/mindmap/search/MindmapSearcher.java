package luceneservice.mindmap.search;

import java.io.File;
import luceneservice.base.Searcher;
import java.io.IOException;
import org.apache.lucene.queryParser.ParseException;

/**
 * 实现Mindmap的搜索
 */
public class MindmapSearcher extends Searcher {

  public static final String[] SEARCH_FIELDS = {"content", "title"};

  public MindmapSearcher(File index_dir_file) {
    super(index_dir_file);
  }

  public String search(MindmapQueryOption query_option) throws IOException, ParseException, Exception {
    MindmapQueryExecuter executer = null;
    
    try{
      executer = new MindmapQueryExecuter(this.index_dir_file, query_option);
      return executer.getXML();
    }finally{
      if(executer != null) executer.close();
    }
  }
  
}