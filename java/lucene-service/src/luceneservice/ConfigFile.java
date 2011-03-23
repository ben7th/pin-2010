package luceneservice;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Properties;

/**
 * 配置文件
 * @author Administrator
 */
public class ConfigFile {

  // 环境标示
  public static final String PRODUCTION_ENV = "production";
  public static final String DEVELOPMENT_ENV = "development";
  // 成员变量
  private String environment;
  private Properties properties = new Properties();

  public ConfigFile(String environment) throws FileNotFoundException, IOException {
    this.environment = environment;
    getProperties();
  }

  private void getProperties() throws FileNotFoundException, IOException {
    FileInputStream inputFile = new FileInputStream("./lib/config_" + environment + ".properties");
    properties.load(inputFile);
    inputFile.close();
  }

  private String getProperty(String key) {
    return properties.getProperty(key);
  }

  public String getNoteFullIndexPath() {
    return getProperty("NOTE_FULL_INDEX_PATH");
  }

  public String getNoteNewestIndexPath() {
    return getProperty("NOTE_NEWEST_INDEX_PATH");
  }

  public String getMindmapIndexPath() {
    return getProperty("MINDMAP_INDEX_PATH");
  }

  public String getFeedIndexPath(){
    return getProperty("FEED_INDEX_PATH");
  }

  public String getMindmapDatabaseUrl() {
    return getProperty("MINDMAP_DATABASE_URL");
  }

  public String getFeedDatabaseUrl() {
    return getProperty("FEED_DATABASE_URL");
  }

  public String getDatabaseUserName() {
    return getProperty("DATABASE_USERNAME");
  }

  public String getDatabasePassword() {
    return getProperty("DATABASE_PASSWORD");
  }
  /**
   *
   * @param args
   * @throws FileNotFoundException
   * @throws IOException
  public static void main(String[] args) throws FileNotFoundException, IOException{
  ConfigFile cf = new ConfigFile("production");
  System.out.println(cf.getDatabasePassword());
  System.out.println(cf.getMindmapDatabaseUrl());
  System.out.println(cf.getDatabaseUserName());
  System.out.println(cf.getMindmapIndexPath());
  System.out.println(cf.getNoteFullIndexPath());
  System.out.println(cf.getNoteNewestIndexPath());
  }
   */
}
