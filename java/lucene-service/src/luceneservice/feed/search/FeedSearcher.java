package luceneservice.feed.search;

import java.io.File;
import luceneservice.base.Searcher;
import java.io.IOException;
import org.apache.lucene.queryParser.ParseException;

/**
 * 对Feed的搜索
 */
public class FeedSearcher extends Searcher {

  public static final String[] SEARCH_FIELDS = {"tag","content","detail"};

  public FeedSearcher(File index_dir_file) {
    super(index_dir_file);
  }

  public String search(FeedQueryOption query_option) throws IOException, ParseException, Exception {
    FeedQueryExecuter executer = null;

    try{
      executer = new FeedQueryExecuter(this.index_dir_file, query_option);
      return executer.getXML();
    }finally{
      if(executer != null) executer.close();
    }
  }
  
}