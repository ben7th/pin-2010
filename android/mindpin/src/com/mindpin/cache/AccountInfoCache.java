package com.mindpin.cache;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.json.JSONException;
import org.json.JSONObject;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.mindpin.Logic.Http;
import com.mindpin.base.utils.FileDirs;

public class AccountInfoCache {
	
	public static void save(String account_info) throws JSONException, IOException   {
		FileUtils.writeStringToFile(get_json_file(), account_info);
		JSONObject json = new JSONObject(account_info);
		InputStream stream = Http.download_image((String)json.get("avatar_url"));
		if(null != stream){
			FileUtils.copyInputStreamToFile(stream, get_avatar_file());
		}
	}
	
	private static File get_avatar_file(){
		return new File(FileDirs.MINDPIN_CACHE_DIR, "logo.png");
	}
	
	private static File get_json_file(){
		return new File(FileDirs.MINDPIN_CACHE_DIR, "info.json");
	}
	
	// 删除缓存的文件
	public static void delete_cache_files(){
		get_avatar_file().delete();
		get_json_file().delete();
	}
	
	// 获取当前缓存的用户名字符串
	public static String get_name() {
		try {
			File file = get_json_file();
			String json_str = IOUtils.toString(new FileInputStream(file));
			JSONObject json = new JSONObject(json_str);
			return (String)json.get("name");
		} catch (Exception e) {
			e.printStackTrace();
			return "";
		}
	}
	
	// 获取当前缓存的头像文件Bitmap对象
	public static Bitmap get_avatar_bitmap(){
		return BitmapFactory.decodeFile(get_avatar_file().getPath());
	}

}
