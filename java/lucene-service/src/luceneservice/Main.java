package luceneservice;

import luceneservice.base.ConfigFile;
import luceneservice.mindmap.LuceneMindmapsService;
import luceneservice.mindmap.LuceneMindmapsServiceHandler;
import luceneservice.feed.LuceneFeedsService;
import luceneservice.feed.LuceneFeedsServiceHandler;
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
  public static TServerTransport serverTransport;

  public static ConfigFile config_file;
  public static File mindmap_index_dir_file;
  public static File feed_index_dir_file;

  /**
   * @param args the command line arguments
   */
  public static void main(String[] args) {
    try {
      String env = args[1].equals(ConfigFile.PRODUCTION_ENV) ? ConfigFile.PRODUCTION_ENV : ConfigFile.DEVELOPMENT_ENV; //不传参数就dev开发模式
      System.out.println("This is " + env + " envrionment ...");

      setConfigFile(env);

      startServer(args[0]);
    } catch (FileNotFoundException ex) {
      ex.printStackTrace();
    } catch (IOException ex) {
      ex.printStackTrace();
    } catch (TTransportException tTransportException) {
      tTransportException.printStackTrace();
    }
  }

  /*
   * 读配置文件
   */
  private static void setConfigFile(String environment) throws FileNotFoundException, IOException {
    config_file = new ConfigFile(environment);
    initAndSetIndexDir();
  }

  /**
   * 初始化索引目录
   */
  private static void initAndSetIndexDir() throws IOException {
    mindmap_index_dir_file = checkOrMkdir(config_file.getMindmapIndexPath());
    feed_index_dir_file = checkOrMkdir(config_file.getFeedIndexPath());
  }

  /**
   * 检查并文件是否存在，若不存在则创建之
   * @param filePath
   */
  public static File checkOrMkdir(String filePath) throws IOException {
    File file = new File(filePath);
    if (!file.exists()) {
      file.mkdirs();
    }
    return file;
  }

  private static void startServer(String type) throws TTransportException {
    if (type.equals("mindmaps")) {
      startMindmapsServer();
      return;
    }

    if(type.equals("feeds")) {
      startFeedsServer();
      return;
    }
  }

  private static void startMindmapsServer() throws TTransportException {
    LuceneMindmapsServiceHandler mindmapHandler = new LuceneMindmapsServiceHandler(mindmap_index_dir_file);
    LuceneMindmapsService.Processor mindmapProcessor = new LuceneMindmapsService.Processor(mindmapHandler);
    serverTransport = new TServerSocket(9091);
    // Use this for a multithreaded server
    // 还有一个是 TSimpleServer
    TServer mindmapServer = new TThreadPoolServer(mindmapProcessor, serverTransport);
    System.out.println("Mindmaps index and search server Starting  ...");
    mindmapServer.serve();
  }

  private static void startFeedsServer() throws TTransportException {
    LuceneFeedsServiceHandler feedsHandler = new LuceneFeedsServiceHandler(feed_index_dir_file);
    serverTransport = new TServerSocket(9092);
    LuceneFeedsService.Processor feedProcessor = new LuceneFeedsService.Processor(feedsHandler);
    TServer feedServer = new TThreadPoolServer(feedProcessor, serverTransport);
    System.out.println("Feeds index and search server Starting  ...");
    feedServer.serve();
  }
}
