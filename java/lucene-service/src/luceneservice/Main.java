package luceneservice;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
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

  private static ConfigFile cf;
  public static TServerTransport serverTransport;

  /**
   * @param args the command line arguments
   */
  public static void main(String[] args) {
    try {
      String env = args[1].equals(ConfigFile.PRODUCTION_ENV) ? ConfigFile.PRODUCTION_ENV : ConfigFile.DEVELOPMENT_ENV; //不穿参数就dev开发模式
      System.out.println("This is " + env + " envrionment ...");
      setConfigFile(env);
      initIndexPath();
      beginServer(args[0]);
    } catch (FileNotFoundException ex) {
      ex.printStackTrace();
    } catch (IOException ex) {
      ex.printStackTrace();
    } catch (TTransportException tTransportException) {
      tTransportException.printStackTrace();
    }
  }

  private static void setConfigFile(String environment) throws FileNotFoundException, IOException {
    cf = new ConfigFile(environment);
  }

  /**
   * 初始化索引目录
   */
  private static void initIndexPath() {
    checkOrMkdir(cf.getMindmapIndexPath());
    checkOrMkdir(cf.getNoteFullIndexPath());
    checkOrMkdir(cf.getNoteNewestIndexPath());
  }

  /**
   * 检查并文件是否存在，若不存在则创建之
   * @param filePath
   */
  public static void checkOrMkdir(String filePath) {
    File file = new File(filePath);
    if (!file.exists()) {
      file.mkdirs();
    }
  }

  private static void beginServer(String type) throws TTransportException {
    if (type.equals("notes")) {
      beginNotesServer();
    } else if (type.equals("mindmaps")) {
      beginMindmapsServer();
    }
  }

  private static void beginNotesServer() throws TTransportException {
    LuceneNotesServiceHandler handler = new LuceneNotesServiceHandler(Main.cf);
    LuceneNotesService.Processor processor = new LuceneNotesService.Processor(handler);
    serverTransport = new TServerSocket(9090);
    // Use this for a multithreaded server
    // 还有一个是 TSimpleServer
    TServer server = new TThreadPoolServer(processor, serverTransport);
    System.out.println("Notes index and search server Starting ...");
    server.serve();
  }

  private static void beginMindmapsServer() throws TTransportException {
    LuceneMindmapsServiceHandler mindmapHandler = new LuceneMindmapsServiceHandler(Main.cf);
    LuceneMindmapsService.Processor mindmapProcessor = new LuceneMindmapsService.Processor(mindmapHandler);
    serverTransport = new TServerSocket(9091);
    // Use this for a multithreaded server
    // 还有一个是 TSimpleServer
    TServer mindmapServer = new TThreadPoolServer(mindmapProcessor, serverTransport);
    System.out.println("Mindmaps index and search server Starting  ...");
    mindmapServer.serve();
  }
}
