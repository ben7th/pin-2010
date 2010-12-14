/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
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
  public static void main(String[] args) {
    try {
      LuceneServiceHandler.initIndexPath();
      LuceneServiceHandler handler = new LuceneServiceHandler();
      LuceneService.Processor processor = new LuceneService.Processor(handler);
      TServerTransport serverTransport = new TServerSocket(9090);
      // Use this for a multithreaded server
      // 还有一个是 TSimpleServer
      TServer server = new TThreadPoolServer(processor, serverTransport);
      System.out.println("Starting the server...");
      server.serve();
    } catch (TTransportException tTransportException) {
      tTransportException.printStackTrace();
    }
  }
}
