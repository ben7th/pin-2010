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
  public final String PRODUCTION_ENV = "production";
  // 成员变量
  private String environment;
  private boolean isProduction = false;
  private Properties properties = new Properties();

  public ConfigFile(String environment) throws FileNotFoundException, IOException {
    this.environment = environment;
    if (this.environment.equals(PRODUCTION_ENV)) {
      System.out.println("This is production envrionment ...");
      isProduction = true;
    }else{
      System.out.println("This is development envrionment ...");
    }
    getProperties();
  }

  private void getProperties() throws FileNotFoundException, IOException {
    FileInputStream inputFile = new FileInputStream("./lib/config.properties");
    properties.load(inputFile);
    inputFile.close();
  }

  private String getProperty(String key){
    return properties.getProperty(key);
  }

  public String getNoteFullIndexPath() {
    return isProduction ? getProperty("NOTE_FULL_INDEX_PATH_PRODUCTION") : getProperty("NOTE_FULL_INDEX_PATH_DEVELOPMENT");
  }

  public String getNoteNewestIndexPath() {
    return isProduction ? getProperty("NOTE_NEWEST_INDEX_PATH_PRODUCTION") : getProperty("NOTE_NEWEST_INDEX_PATH_DEVELOPMENT");
  }

  public String getMindmapIndexPath() {
    return isProduction ? getProperty("MINDMAP_INDEX_PATH_PRODUCTION") : getProperty("MINDMAP_INDEX_PATH_DEVELOPMENT");
  }

  public String getDatabaseUrl() {
    return isProduction ? getProperty("DATABASE_URL_PRODUCTION") : getProperty("DATABASE_URL_DEVELOPMENT");
  }

  public String getDatabaseUserName() {
    return isProduction ? getProperty("DATABASE_USERNAME_PRODUCTION") : getProperty("DATABASE_USERNAME_DEVELOPMENT");
  }

  public String getDatabasePassword() {
    return isProduction ? getProperty("DATABASE_PASSWORD_PRODUCTION") : getProperty("DATABASE_PASSWORD_DEVELOPMENT");
  }
  
  /**
   *
   * @param args
   * @throws FileNotFoundException
   * @throws IOException
  public static void main(String[] args) throws FileNotFoundException, IOException{
    ConfigFile cf = new ConfigFile("");
    System.out.println(cf.getDatabasePassword());
    System.out.println(cf.getDatabaseUrl());
    System.out.println(cf.getDatabaseUserName());
    System.out.println(cf.getMindmapIndexPath());
    System.out.println(cf.getNoteFullIndexPath());
    System.out.println(cf.getNoteNewestIndexPath());
  }
   */
}
