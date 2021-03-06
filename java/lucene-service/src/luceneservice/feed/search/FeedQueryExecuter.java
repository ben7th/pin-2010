package luceneservice.feed.search;

import java.io.File;
import java.io.IOException;
import luceneservice.base.QueryExecuter;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.search.FieldCacheTermsFilter;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.store.FSDirectory;
import org.wltea.analyzer.lucene.IKQueryParser;
import org.wltea.analyzer.lucene.IKSimilarity;

public class FeedQueryExecuter extends QueryExecuter {
  public FeedQueryExecuter(File index_dir_file, FeedQueryOption query_option) throws IOException{
    this.query_option = query_option;

    this.fs_dir = FSDirectory.open(index_dir_file);
    this.index_searcher = new IndexSearcher(fs_dir);
    this.index_searcher.setSimilarity(new IKSimilarity());
    this.query = IKQueryParser.parseMultiField(FeedSearcher.SEARCH_FIELDS, query_option.query_str);

    if(query_option.creator_id_str != null){
      filter = new FieldCacheTermsFilter("creator_id", query_option.creator_id_str);
    }
  }

  @Override
  public String[][] getResultArray(ScoreDoc[] partial_result) throws CorruptIndexException, IOException {
    String[][] arrays = new String[partial_result.length][4];

    for (int i = 0; i < partial_result.length; i++) {
      Document doc = index_searcher.doc(partial_result[i].doc);

      arrays[i][0] = doc.get("id");

      arrays[i][1] = makeHighlight(doc.get("content"));

      arrays[i][2] = makeHighlight(doc.get("detail"));

      arrays[i][3] = String.valueOf(partial_result[i].score);
    }
    return arrays;
  }

  @Override
  public String resultXML(String[][] arrays) {
    StringBuilder sb = new StringBuilder();

    sb.append("<search_results time='").append(query_time)
      .append("' count='").append(arrays.length)
      .append("' total_count='").append(all_result.length)
      .append("'>");

    for (int i = 0; i < arrays.length; i++) {
      sb.append("<search_result>");
      sb.append("<id>").append(arrays[i][0]).append("</id>");
      sb.append("<content> <![CDATA[").append(arrays[i][1]).append("]]> </content>");
      sb.append("<detail> <![CDATA[").append(arrays[i][2]).append("]]> </detail>");
      sb.append("<score>").append(arrays[i][3]).append("</score>");
      sb.append("</search_result>");
    }
    sb.append("</search_results>");
    
    return sb.toString();
  }

}