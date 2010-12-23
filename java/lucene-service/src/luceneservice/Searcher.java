package luceneservice;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.highlight.Highlighter;
import org.apache.lucene.search.highlight.InvalidTokenOffsetsException;
import org.apache.lucene.search.highlight.QueryScorer;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.wltea.analyzer.lucene.IKQueryParser;
import org.wltea.analyzer.lucene.IKSimilarity;
import org.apache.lucene.search.highlight.SimpleFragmenter;
import org.apache.lucene.search.highlight.SimpleHTMLFormatter;
import org.wltea.analyzer.lucene.IKAnalyzer;

/**
 *
 * @author Administrator
 */
public class Searcher {

  private File indexDir;     // 索引路径
  private String q;          // 搜索字符串
  private Integer start;     // 要查询的开始角标
  private Integer count;     // 要查询的数量
  protected IndexSearcher indexSearch = null;
  protected Query query;
  protected ScoreDoc[] allSearchResult;
  protected ScoreDoc[] returnSearchResult;
  protected long searchTime;

  Searcher(String indexDir, String q) {
    this.indexDir = new File(indexDir);
    this.q = q;
  }

  Searcher(String indexDir, String q, Integer start, Integer count) {
    this.indexDir = new File(indexDir);
    this.q = q;
    this.start = start;
    this.count = count;
  }

  /**
   * 检测索引目录是否存在，以及索引目录下面是否存在生成的索引文件
   */
  private void checkIndexDir() throws Exception {
    if (!indexDir.exists() || !indexDir.isDirectory()) {
      throw new Exception(indexDir + "does not exist or is a directory");
    }
    if (indexDir.listFiles().length == 0) {
      throw new Exception(indexDir + "has none index files");
    }
  }

  /**
   * 进行查找
   * @param searchFields
   * @return
   * @throws IOException
   * @throws ParseException
   * @throws Exception
   */
  public String search(String[] searchFields) throws IOException, ParseException, Exception {
    try {
      checkIndexDir();
      Directory fsDir = FSDirectory.open(indexDir);
      indexSearch = new IndexSearcher(fsDir);
      indexSearch.setSimilarity(new IKSimilarity());
      query = IKQueryParser.parseMultiField(searchFields, q);
      long startTime = new Date().getTime();
      allSearchResult = indexSearch.search(query, null, 100000).scoreDocs;
      returnSearchResult = getScoreDocs();
      long endTime = new Date().getTime();
      searchTime = endTime - startTime;
      // 输出统计数据
      System.out.println("Found " + returnSearchResult.length + " document(s) (in " + searchTime + " millisenconds) that matched query '" + q + "'");
      return getResult();
    } finally {
      indexSearch.close();
    }
  }

  /**
   * 根据start和count得知是否存在决定搜索结果的数量
   * @return
   */
  private ScoreDoc[] getScoreDocs() {
    if (start == null || count == null) {
      return allSearchResult;
    }
    if (start > allSearchResult.length) {
      return new ScoreDoc[0];
    }
    List<ScoreDoc> list = new ArrayList<ScoreDoc>();
    for (int i = 0, j = start; i < count && j < allSearchResult.length; i++, j++) {
      list.add(allSearchResult[j]);
    }
    return list.toArray(new ScoreDoc[list.size()]);
  }

  /**
   * 获取高亮字符串
   * @param content
   * @return
   * @throws IOException
   * @throws InvalidTokenOffsetsException
   */
  protected String getHighlightString(String content) throws IOException, InvalidTokenOffsetsException {
    SimpleHTMLFormatter sHtmlF = new SimpleHTMLFormatter("<span class='loud'>", "</span>");
    Highlighter highlighter = new Highlighter(sHtmlF, new QueryScorer(query));
    highlighter.setTextFragmenter(new SimpleFragmenter(100));
    String highStr = "";
    if (content != null) {
      TokenStream tokenStream = new IKAnalyzer().tokenStream("", new StringReader(content));
      highStr = highlighter.getBestFragment(tokenStream, content);
    }
    return highStr;
  }

  /**
   * 处理结果，返回xml文档
   * @return
   * @throws CorruptIndexException
   * @throws IOException
   * @throws InvalidTokenOffsetsException
   */
  protected String getResult() throws CorruptIndexException, IOException, InvalidTokenOffsetsException {
    return "";
  }
}
