package luceneservice;

import java.io.IOException;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.search.highlight.InvalidTokenOffsetsException;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

/**
 * 实现Mindmap的搜索
 * @author Administrator
 */
public class MindmapSearcher extends Searcher {

  public static final String[] SEARCH_FIELDS = {"content", "title"};

  MindmapSearcher(String indexDir, String q) {
    super(indexDir,q);
  }

  MindmapSearcher(String indexDir, String q, Integer start, Integer count) {
    super(indexDir,q,start,count);
  }

  /**
   * 重写父类的获取结果方法
   */
  @Override
  protected String getResult() throws CorruptIndexException, IOException, InvalidTokenOffsetsException {
    String[][] arrays = new String[returnSearchResult.length][4];
    for (int i = 0; i < returnSearchResult.length; i++) {
      Document doc = indexSearch.doc(returnSearchResult[i].doc);
      arrays[i][0] = doc.get("id");
      arrays[i][1] = getHighlightString(doc.get("content"));
      String titleHighlight = getHighlightString(doc.get("title"));
      arrays[i][2] = (titleHighlight==null || titleHighlight.equals("")) ? doc.get("title") : titleHighlight ;
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
      sb.append("<id>").append(arrays[i][0]).append("</id>");
      sb.append("<content> <![CDATA[").append(arrays[i][1]).append("]]> </content>");
      sb.append("<title> <![CDATA[").append(arrays[i][2]).append("]]> </title>");
      sb.append("<score>").append(arrays[i][3]).append("</score>");
      sb.append("</search_result>");
    }
    sb.append("</search_results>");
    return sb.toString();
  }

  /**
  public static void main(String args[]) throws IOException, ParseException, Exception {
    String indexDir = "\\\\192.168.1.8\\root\\web\\2010\\lucene\\mindmaps\\index";
    String[] qs = {"法规"}; // 要查询的单词

    for (String q : qs) {
      Searcher s = new MindmapSearcher(indexDir, q);
      System.out.println(s.search(MindmapSearcher.SEARCH_FIELDS));
    }
  }
  */
}
