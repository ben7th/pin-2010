package lucene;

import org.apache.thrift.server.TServer;
import org.apache.thrift.server.TThreadPoolServer;
import org.apache.thrift.transport.TServerSocket;
import org.apache.thrift.transport.TServerTransport;
import org.apache.thrift.transport.TTransportException;

/**
 *
 * @author Administrator
 */
public class Main {

  /**
   * @param args the command line arguments
   */
  public static void main(String[] args) throws ClassNotFoundException {
    try {
      if (args[0].equals("notes")) {
        beginNotesServer();
      } else if (args[0].equals("mindmaps")) {
        beginMindmapsServer();
      }
    } catch (TTransportException tTransportException) {
      tTransportException.printStackTrace();
    }
  }

  public static void beginNotesServer() throws TTransportException {
    LuceneNotesServiceHandler.initIndexPath();
    LuceneNotesServiceHandler handler = new LuceneNotesServiceHandler();
    LuceneNotesService.Processor processor = new LuceneNotesService.Processor(handler);
    TServerTransport serverTransport = new TServerSocket(9090);
    // Use this for a multithreaded server
    // 还有一个是 TSimpleServer
    TServer server = new TThreadPoolServer(processor, serverTransport);
    System.out.println("Notes Starting the server...");
    server.serve();
  }

  public static void beginMindmapsServer() throws TTransportException {
    LuceneMindmapsServiceHandler.initIndexPath();
    LuceneMindmapsServiceHandler mindmapHandler = new LuceneMindmapsServiceHandler();
    LuceneMindmapsService.Processor mindmapProcessor = new LuceneMindmapsService.Processor(mindmapHandler);
    TServerTransport newServerTransport = new TServerSocket(9091);
    // Use this for a multithreaded server
    // 还有一个是 TSimpleServer
    TServer mindmapServer = new TThreadPoolServer(mindmapProcessor, newServerTransport);
    System.out.println("Mindmaps Starting the server...");
    mindmapServer.serve();
  }
}
