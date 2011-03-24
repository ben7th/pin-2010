package luceneservice;

import java.io.IOException;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.search.highlight.InvalidTokenOffsetsException;

/**
 * 对Feed的搜索
 * @author Administrator
 */
public class FeedSearcher extends Searcher {

  public static final String[] SEARCH_FIELDS = {"content"};

  FeedSearcher(String indexDir, String q) {
    super(indexDir, q);
  }

  FeedSearcher(String indexDir, String q, Integer start, Integer count) {
    super(indexDir, q, start, count);
  }

  /**
   * 根据Feed的数据内容 重写父类的获取结果方法
   */
  @Override
  protected String getResult() throws CorruptIndexException, IOException, InvalidTokenOffsetsException {
    String[][] arrays = new String[returnSearchResult.length][4];
    for (int i = 0; i < returnSearchResult.length; i++) {
      Document doc = indexSearch.doc(returnSearchResult[i].doc);
      arrays[i][0] = doc.get("id");
      arrays[i][1] = getHighlightString(doc.get("content"));
      arrays[i][2] = String.valueOf(returnSearchResult[i].score);
    }
    return resultXML(arrays);
  }

  /**
   * 最后以xml形式输出的结果
   * @param arrays
   * @return
   */
  private String resultXML(String[][] arrays) {
    StringBuilder sb = new StringBuilder();
    sb.append("<search_results time='").append(searchTime).append("' count='").append(arrays.length).append("' total_count='").append(allSearchResult.length).append("'>");
    for (int i = 0; i < arrays.length; i++) {
      sb.append("<search_result>");
      sb.append("<id>").append(arrays[i][0]).append("</id>");
      sb.append("<content> <![CDATA[").append(arrays[i][1]).append("]]> </content>");
      sb.append("<score>").append(arrays[i][2]).append("</score>");
      sb.append("</search_result>");
    }
    sb.append("</search_results>");
    return sb.toString();
  }

  /**
   * 测试函数
   * @param args
   * @throws Exception
  public static void main(String[] args) throws Exception {
    String indexDir = "\\\\192.168.1.8\\root\\root\\mindpin_base\\lucene_index\\feeds\\index";
    String[] qs = {"广告"}; // 要查询的单词

    for (String q : qs) {
      Searcher s = new FeedSearcher(indexDir, q);
      System.out.println(s.search(FeedSearcher.SEARCH_FIELDS));
      System.out.println(s.searchFeedsByUserEmail(MindmapSearcher.SEARCH_FIELDS, "qdclw1986@sina.cn"));
    }
  }
   */
}
