/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package lucenefornotes;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.util.Version;
import org.wltea.analyzer.lucene.IKQueryParser;
import org.wltea.analyzer.lucene.IKSimilarity;

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

  /*
  public static void main(String[] args) throws Exception {
  String indexDir = "index";
  String[] qs = {"Koreas", "country", "China", "record", "situation", "hello", "中国", "学习", "私有", "孤岛"}; // 要查询的单词

  for (String q : qs) {
  Searcher s = new Searcher(indexDir, q);
  System.out.println(s.search());
  }
  }
   *
   */
  
  
  public String search() throws IOException, ParseException, Exception {
    if (!indexDir.exists() || !indexDir.isDirectory()) {
      throw new Exception(indexDir + "does not exist or is a directory");
    }
    Directory fsDir = FSDirectory.open(indexDir);
    IndexSearcher is = new IndexSearcher(fsDir);
    is.setSimilarity(new IKSimilarity());
    //QueryParser qp = new QueryParser(Version.LUCENE_30,"filename,content",new StandardAnalyzer(Version.LUCENE_30));
    //QueryParser qp = new QueryParser(Version.LUCENE_CURRENT, "content", new StandardAnalyzer(Version.LUCENE_CURRENT));
    String[] fileds = {"content","filename"};
    Query query = IKQueryParser.parseMultiField(fileds,q);
    long start = new Date().getTime();
    TopDocs tds = is.search(query, null, 1000);
    ScoreDoc[] hits = tds.scoreDocs;
    long end = new Date().getTime();
    // 输出统计数据
    System.err.println("Found " + hits.length + " document(s) (in " + (end - start) + " millisenconds) that matched query '" + q + "'");
    return result(hits, is);
  }

  private String result(ScoreDoc[] hits, IndexSearcher is) throws CorruptIndexException, IOException {

    // 输出搜索出的文件名
    String[] arrays = new String[hits.length];
    for (int i = 0; i < hits.length; i++) {
      Document doc = is.doc(hits[i].doc);
      arrays[i] = doc.get("filename");
      //System.out.println(doc.get("filename"));
    }
    return resultXML(arrays);
  }

  private String resultXML(String[] arrays) {
    StringBuilder sb = new StringBuilder();
    sb.append("<search_results>");
    for (int i = 0; i < arrays.length; i++) {
      sb.append("<search_result>");
      sb.append(arrays[i]);
      sb.append("</search_result>");
    }
    sb.append("</search_results>");
    return sb.toString();
  }
}
