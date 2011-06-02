package luceneservice.base;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.search.Filter;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.highlight.Highlighter;
import org.apache.lucene.search.highlight.InvalidTokenOffsetsException;
import org.apache.lucene.search.highlight.QueryScorer;
import org.apache.lucene.search.highlight.SimpleFragmenter;
import org.apache.lucene.search.highlight.SimpleHTMLFormatter;
import org.apache.lucene.store.FSDirectory;
import org.wltea.analyzer.lucene.IKAnalyzer;

/**
 *
 * @author Administrator
 */
public abstract class QueryExecuter {
  public FSDirectory fs_dir;
  public IndexSearcher index_searcher;
  public QueryOption query_option;
  public Query query;
  public Filter filter;

  public ScoreDoc[] all_result;
  public long query_time;

  public void close() throws IOException{
    this.fs_dir.close();
    this.index_searcher.close();
  }

  /**
   * 根据start和count得知是否存在决定搜索结果的数量
   */
  public ScoreDoc[] getPartialScoreDocs() {
    int start = query_option.start;
    int count = query_option.count;

    //如果没有传入start和count 直接返回全部结果集
    if(start == -1 || count == -1){
      return all_result;
    }

    // 如果start大于结果集长度，返回空结果集
    if (start > all_result.length) {
      return new ScoreDoc[0];
    }

    // 从start开始找count个
    List<ScoreDoc> list = new ArrayList<ScoreDoc>();
    for (int i = 0, j = start; i < count && j < all_result.length; i++, j++) {
      list.add(all_result[j]);
    }
    return list.toArray(new ScoreDoc[list.size()]);
  }

  /**
   * 获取高亮字符串
   */
  public String makeHighlight(String str) {
    SimpleHTMLFormatter html_formater = new SimpleHTMLFormatter("<span class='search-highlight'>", "</span>");
    Highlighter highlighter = new Highlighter(html_formater, new QueryScorer(query));
    highlighter.setTextFragmenter(new SimpleFragmenter(200));

    String re_str = "";
    if (str != null) {
      TokenStream tokenStream = new IKAnalyzer().tokenStream("", new StringReader(str));
      try {
        re_str = highlighter.getBestFragment(tokenStream, str);
        if(re_str == null || "".equals(re_str)) re_str = str;
      } catch (IOException ex) {
        re_str = str;
      } catch (InvalidTokenOffsetsException ex) {
        re_str = str;
      }
    }
    return re_str;
  }

  public String getXML() {
    try {
      long start_time = new Date().getTime();
      all_result = index_searcher.search(query, filter, 100000).scoreDocs;
      long end_time = new Date().getTime();
      query_time = end_time - start_time;

      ScoreDoc[] partial_result = getPartialScoreDocs();
      String[][] arrays = getResultArray(partial_result);
      String xmlstr = resultXML(arrays);

      return xmlstr;
    } catch (IOException ex) {
      System.out.println("Search executer error.");
      return "<search_results></search_results>";
    }
  }
  
  public abstract String[][] getResultArray(ScoreDoc[] partial_result) throws CorruptIndexException, IOException;

  public abstract String resultXML(String[][] arrays);
  
}
