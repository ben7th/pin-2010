package luceneservice;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.tokenattributes.TermAttribute;
import org.wltea.analyzer.lucene.IKAnalyzer;

/**
 * 对一段文字进行分词
 * @author Administrator
 */
public class IkAnalyzerWord {

  private String resource;
  private List<String> result = new ArrayList<String>();

  public IkAnalyzerWord(String resource) throws IOException {
    this.resource = resource;
    analyzer();
  }

  private void analyzer() throws IOException {
    Analyzer analyzer = new IKAnalyzer();
    TokenStream ts = analyzer.tokenStream("*", new StringReader(resource));
    ts.addAttribute(TermAttribute.class);
    while (ts.incrementToken()) {
      TermAttribute ta = ts.getAttribute(TermAttribute.class);
      result.add(ta.term());
    }
  }

  public List<String> getResult() {
    return this.result;
  }

  /**
  public static void main(String[] args) throws IOException {
    IkAnalyzerWord ik = new IkAnalyzerWord("今天的大风终于小了，但是又起雾了今天的大风终于小了，但是又起雾了");
    System.out.println(ik.getResult());
  }
   */
}
