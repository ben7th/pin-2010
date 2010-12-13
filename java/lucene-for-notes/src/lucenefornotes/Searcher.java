/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package lucenefornotes;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.util.Date;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.TermFreqVector;
import org.apache.lucene.index.TermPositionVector;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
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
 * 实现搜索
 * @author Administrator
 */
public class Searcher {

  private File indexDir;
  private String q;

  Searcher(String indexDir, String q) {
    this.indexDir = new File(indexDir);
    this.q = q;
  }

  public static void main(String[] args) throws Exception {
    String indexDir = "\\\\192.168.1.8\\root\\web\\2010\\lucene\\notes\\index";
    String[] qs = {"中国", "小说", "寻黄"}; // 要查询的单词

    for (String q : qs) {
      Searcher s = new Searcher(indexDir, q);
      System.out.println(s.search());
    }
  }

  public String search() throws IOException, ParseException, Exception {
    if (!indexDir.exists() || !indexDir.isDirectory()) {
      throw new Exception(indexDir + "does not exist or is a directory");
    }
    Directory fsDir = FSDirectory.open(indexDir);
    IndexSearcher is = new IndexSearcher(fsDir);
    is.setSimilarity(new IKSimilarity());
    String[] fileds = {"content", "filename"};
    Query query = IKQueryParser.parseMultiField(fileds, q);
    long start = new Date().getTime();
    TopDocs tds = is.search(query, null, 1000);
    ScoreDoc[] hits = tds.scoreDocs;
    long end = new Date().getTime();
    // 输出统计数据
    System.err.println("Found " + hits.length + " document(s) (in " + (end - start) + " millisenconds) that matched query '" + q + "'");
    return result(hits, is, (end - start), query);
  }

  private String result(ScoreDoc[] hits, IndexSearcher is, long time, Query query) throws CorruptIndexException, IOException, InvalidTokenOffsetsException {
    // 输出搜索出的文件名
    String[][] arrays = new String[hits.length][2];
    for (int i = 0; i < hits.length; i++) {
      Document doc = is.doc(hits[i].doc);
      //对要高亮显示的字段格式化，这里只是加红色显示和加粗
      SimpleHTMLFormatter sHtmlF = new SimpleHTMLFormatter("<span color='loud'>", "</span>");
      Highlighter highlighter = new Highlighter(sHtmlF, new QueryScorer(query));
      highlighter.setTextFragmenter(new SimpleFragmenter(50));
      String content = doc.get("content");
      String highStr = "";
      if (content!=null) {
        TokenStream tokenStream = new IKAnalyzer().tokenStream("", new StringReader(doc.get("content")));
        highStr = highlighter.getBestFragment(tokenStream, doc.get("content"));
      }
      System.out.println();

      arrays[i][0] = doc.get("filepath");
      arrays[i][1] = highStr;
      //System.out.println(doc.get("filename"));
    }
    return resultXML(arrays, time);
  }

  // 最后以xml形式输出的结果
  private String resultXML(String[][] arrays, long time) {
    StringBuilder sb = new StringBuilder();
    sb.append("<search_results time='" + time + "'>");
    for (int i = 0; i < arrays.length; i++) {
      sb.append("<search_result>");
      sb.append("<path>" + arrays[i][0] + "</path>");
      sb.append("<highlight>" + arrays[i][1] + "</highlight>");
      sb.append("</search_result>");
    }
    sb.append("</search_results>");
    return sb.toString();
  }
}
