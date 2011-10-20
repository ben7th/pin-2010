package com.mindpin.Logic;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.http.cookie.Cookie;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import com.mindpin.base.utils.FileDirs;
import com.mindpin.database.User;

public class Account {
	
	public static int save(List<Cookie> cookies, String info) throws JSONException, IOException   {
		JSONObject json = new JSONObject(info);
		int user_id = (Integer)json.get("id");
		String name = (String)json.get("name");
		String avatar_url = (String)json.get("avatar_url");
		
		// 保存头像
		InputStream stream = Http.download_image(avatar_url);
		if(null != stream){
			FileUtils.copyInputStreamToFile(stream, get_avatar_file(user_id));
		}
		
		// 保存个人信息
		String cookies_str = cookies_list_to_cookies_str(cookies);
		User user = User.find(user_id);
		if(null == user){
			User.insert(user_id, name, cookies_str, info);
		}else{
			User.update(user_id, name, cookies_str ,info);
		}
		
		
		return user_id;
	}
	
	
	private static String cookies_list_to_cookies_str(List<Cookie> cookies) {
		try {
			JSONArray json_arr = new JSONArray();
			for (Cookie cookie : cookies) {
				JSONObject json = new JSONObject();
				json.put("name", cookie.getName());

				json.put("value", cookie.getValue());

				json.put("domain", cookie.getDomain());
				json.put("path", cookie.getPath());
				json_arr.put(json);
			}
			return json_arr.toString();
		} catch (JSONException e) {
			e.printStackTrace();
			return "";
		}
	}


	// 删除缓存的文件
	public static void delete(int user_id){
		User.destroy(user_id);
		get_avatar_file(user_id).delete();
	}
	
	// 获取当前缓存的头像文件Bitmap对象
	public static Bitmap get_avatar_bitmap(int user_id){
		return BitmapFactory.decodeFile(get_avatar_file(user_id).getPath());
	}
	
	private static File get_avatar_file(int user_id){
		return new File(FileDirs.mindpin_user_data_dir(user_id), "logo.png");
	}
}
