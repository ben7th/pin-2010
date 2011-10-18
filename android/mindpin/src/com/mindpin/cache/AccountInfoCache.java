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
import android.os.Environment;

import com.mindpin.Logic.Http;

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
		return new File(get_or_create_cache_dir(),"logo.png");
	}
	
	private static File get_json_file(){
		return new File(get_or_create_cache_dir(),"info.json");
	}

	// ���ػ���Ŀ¼��û�еĻ��ʹ���һ��
	private static File get_or_create_cache_dir(){
		File cache_dir = new File(
			Environment.getExternalStorageDirectory().getPath() + "/mindpin/cache/"
		);
		if (!cache_dir.exists()) {
			cache_dir.mkdirs();
		}
		return cache_dir;
	}
	
	// ɾ��������ļ�
	public static void delete_cache_files(){
		get_avatar_file().delete();
		get_json_file().delete();
	}
	
	// ��ȡ��ǰ������û����ַ���
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
	
	// ��ȡ��ǰ�����ͷ���ļ�Bitmap����
	public static Bitmap get_avatar_bitmap(){
		return BitmapFactory.decodeFile(get_avatar_file().getPath());
	}

}
