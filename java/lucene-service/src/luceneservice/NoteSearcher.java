package luceneservice;

import java.io.IOException;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.search.highlight.InvalidTokenOffsetsException;

/**
 * 实现Note的搜索
 * @author Administrator
 */
public class NoteSearcher extends Searcher {

  public static final String[] SEARCH_FIELDS = {"content", "filename"};

  NoteSearcher(String indexDir, String q) {
    super(indexDir, q);
  }

  NoteSearcher(String indexDir, String q, Integer start, Integer count) {
    super(indexDir, q, start, count);
  }

  /**
   * 重写父类的获取结果方法
   */
  @Override
  protected String getResult() throws CorruptIndexException, IOException, InvalidTokenOffsetsException {
    String[][] arrays = new String[returnSearchResult.length][4];
    for (int i = 0; i < returnSearchResult.length; i++) {
      Document doc = indexSearch.doc(returnSearchResult[i].doc);
      arrays[i][0] = doc.get("filepath");
      arrays[i][1] = getHighlightString(doc.get("content"));
      arrays[i][2] = doc.get("commitid");
      arrays[i][3] = String.valueOf(returnSearchResult[i].score);
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
      sb.append("<path>").append(arrays[i][0]).append("</path>");
      sb.append("<highlight> <![CDATA[").append(arrays[i][1]).append("]]> </highlight>");
      sb.append("<commit_id>").append(arrays[i][2]).append("</commit_id>");
      sb.append("<score>").append(arrays[i][3]).append("</score>");
      sb.append("</search_result>");
    }
    sb.append("</search_results>");
    return sb.toString();
  }

  /**
  public static void main(String[] args) throws Exception {
    String indexDir = "\\\\192.168.1.8\\root\\web\\2010\\lucene\\notes\\full_index";
    String[] qs = {"足球"}; // 要查询的单词

    for (String q : qs) {
      Searcher s = new NoteSearcher(indexDir, q);
      System.out.println(s.search(NoteSearcher.SEARCH_FIELDS));
    }
  }
 */
}
