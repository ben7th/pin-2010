package com.mindpin.cache;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.json.JSONException;
import org.json.JSONObject;
import android.os.Environment;
import com.mindpin.Logic.Http;

public class AccountInfoCache {
	
	public static void save(String info) {
		try {
			FileUtils.writeStringToFile(get_info_file(), info);
			JSONObject json = new JSONObject(info);
			InputStream is = Http.download_logo((String)json.get("logo"));
			if(is !=null){
				FileUtils.copyInputStreamToFile(is,get_logo_file());
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}catch(IOException e){
			e.printStackTrace();
		}
	}
	
	private static File get_logo_file(){
		File cache_dir = new File(Environment.getExternalStorageDirectory()
				.getPath() + "/mindpin/cache/");
		if (!cache_dir.exists()) {
			cache_dir.mkdirs();
		}
		return new File(cache_dir,"logo.png");
	}
	
	private static File get_info_file(){
		File cache_dir = new File(Environment.getExternalStorageDirectory()
				.getPath() + "/mindpin/cache/");
		if (!cache_dir.exists()) {
			cache_dir.mkdirs();
		}
		return new File(cache_dir,"info.json");
	}

	public static String get_name() {
		try {
			File lf = get_info_file();
			String json_str = IOUtils.toString(new FileInputStream(lf));
			JSONObject json = new JSONObject(json_str);
			return (String)json.get("name");
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return "";
		} catch (IOException e) {
			e.printStackTrace();
			return "";
		} catch (JSONException e) {
			e.printStackTrace();
			return "";
		}
	}

	public static String get_logo_path() {
		return get_logo_file().getPath();
	}

}
