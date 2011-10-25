package com.mindpin.database;

import java.io.File;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.http.cookie.Cookie;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.mindpin.R;
import com.mindpin.Logic.Global;
import com.mindpin.Logic.Http;
import com.mindpin.base.utils.FileDirs;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

public class User extends BaseModel {
	public int user_id;
	public String name;
	public String cookies;
	public String info;
	
	private User(int user_id, String name, String cookies, String info){
		this.user_id = user_id;
		this.name = name;
		this.cookies = cookies;
		this.info = info;
	}
	
	public User(List<Cookie> cookies_list, String info) throws JSONException{
		JSONObject json = new JSONObject(info);
		
		this.user_id = (Integer) json.get("id");
		this.name = (String) json.get("name");
		this.cookies = cookies_list_to_cookies_str(cookies_list);
		this.info = info;
	}
	
	public boolean is_v2_activate() {
		try {
			JSONObject info_json = new JSONObject(info);
			return (Boolean) info_json.get("v2_activate");
		} catch (JSONException e) {
			return false;
		}
	}
	
	private String get_avatar_url() throws JSONException {
		JSONObject json = new JSONObject(info);
		return (String) json.get("avatar_url");
	}
	
	private File get_avatar_file(){
		return new File(FileDirs.mindpin_user_data_dir(user_id), "logo.png");
	}
	
	public Bitmap get_avatar_bitmap(){
		File file = get_avatar_file();
		
		if(file.exists()){
			return BitmapFactory.decodeFile(file.getPath());
		}else{
			Drawable draw = Global.application_context.getResources().getDrawable(R.drawable.user_default_avatar_normal);
			return ((BitmapDrawable)draw).getBitmap();  
		}
	}
	
	public static int count(){
		SQLiteDatabase db = get_read_db();
		Cursor cursor = db.query(Constants.TABLE_USERS,new String[]{Constants.KEY_ID}, null, null, null, null, null);
		int count = cursor.getCount();
		db.close();
		return count;
	}
	
	public static User find(int user_id){
		Cursor cursor = query_one(
			Constants.TABLE_USERS,
			new String[]{
				Constants.KEY_ID,
				Constants.TABLE_USERS__USER_ID,
				Constants.TABLE_USERS__NAME,
				Constants.TABLE_USERS__COOKIES,
				Constants.TABLE_USERS__INFO
			}, 
			Constants.TABLE_USERS__USER_ID + " = "+ user_id, 
			null, null, null, null
		);
		
		if(null != cursor){
			String name = cursor.getString(2);
			String cookies = cursor.getString(3);
			String info = cursor.getString(4);
			return new User(user_id, name, cookies, info);
		}else{
			return null;
		}
	}
	
	public static ArrayList<User> all(){
		SQLiteDatabase db = get_read_db();
		Cursor cursor = db.query(
			Constants.TABLE_USERS,
			new String[]{
				Constants.KEY_ID,
				Constants.TABLE_USERS__USER_ID,
				Constants.TABLE_USERS__NAME,
				Constants.TABLE_USERS__COOKIES,
				Constants.TABLE_USERS__INFO
			}, 
			null, null, null, null, Constants.KEY_ID + " asc"
		);
		
		ArrayList<User> users = new ArrayList<User>();
		while(cursor.moveToNext()){
			int user_id = cursor.getInt(1);
			String name = cursor.getString(2);
			String cookies = cursor.getString(3);
			String info = cursor.getString(4);
			users.add(new User(user_id, name, cookies, info));
		}
		db.close();
		return users;
	}
	
	private static String cookies_list_to_cookies_str(List<Cookie> cookies) {
		try {
			JSONArray json_arr = new JSONArray();
			for (Cookie cookie : cookies) {
				JSONObject json = new JSONObject();
				json.put("name", 	cookie.getName());
				json.put("value", 	cookie.getValue());
				json.put("domain", 	cookie.getDomain());
				json.put("path", 	cookie.getPath());
				json_arr.put(json);
			}
			return json_arr.toString();
		} catch (JSONException e) {
			e.printStackTrace();
			return "";
		}
	}
	
	// 保存
	public boolean save(){
		try {
			String avatar_url = get_avatar_url();
			
			// 保存头像文件
			InputStream stream = Http.download_image(avatar_url);
			if(null != stream){
				FileUtils.copyInputStreamToFile(stream, get_avatar_file());
			}
			
			// 保存数据库信息
			SQLiteDatabase db = get_write_db();
			
			ContentValues values = new ContentValues();
			values.put(Constants.TABLE_USERS__USER_ID, 	user_id);
			values.put(Constants.TABLE_USERS__NAME, 	name);
			values.put(Constants.TABLE_USERS__COOKIES, 	cookies);
			values.put(Constants.TABLE_USERS__INFO, 	info);
			
			User user = find(user_id);
			if(null == user){
				db.insert(Constants.TABLE_USERS, null, values);
			}else{
				db.update(Constants.TABLE_USERS, values, Constants.TABLE_USERS__USER_ID + " = "+ user_id, null);
			}
			db.close();
			
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	
	// 删除
	public boolean destroy(){
		try {
			// 删除数据库信息
			SQLiteDatabase db = get_write_db();
			db.execSQL("DELETE FROM " + Constants.TABLE_USERS + " WHERE "
					+ Constants.TABLE_USERS__USER_ID + " = ?",
					new Object[] { user_id });
			db.close();
			
			// 删除头像文件
			get_avatar_file().delete();
			
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
}
