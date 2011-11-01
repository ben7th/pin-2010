package com.mindpin.database;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.mindpin.application.MindpinApplication;
import com.mindpin.base.utils.BaseUtils;

public class Feed {
	public int feed_id;
	public String title;
	public String detail;
	public ArrayList<String> photos_middle;
	public ArrayList<String> photos_large;
	public ArrayList<String> photos_thumbnail;
	public int user_id;
	public String user_name;
	public String user_avatar_url;
	public long updated_at;
	public String json;
	
	public Feed(String json){
		try{
			JSONObject json_obj = new JSONObject(json);
			
			this.feed_id 			= (Integer) json_obj.get("id");
			this.title 				= (String) json_obj.get("title");
			this.detail 			= (String) json_obj.get("detail");
			this.photos_middle 		= json_array_to_array_list((JSONArray) json_obj.get("photos_middle"));
			this.photos_large 		= json_array_to_array_list((JSONArray) json_obj.get("photos_large"));
			this.photos_thumbnail 	= json_array_to_array_list((JSONArray) json_obj.get("photos_thumbnail"));
			this.updated_at 		= BaseUtils.parse_iso_time_string_to_long((String)json_obj.get("updated_at"));
			
			JSONObject user = (JSONObject)json_obj.get("user");
			
			this.user_id 			= (Integer) user.getInt("id");
			this.user_name 			= (String) user.get("name");
			this.user_avatar_url 	= (String) user.get("avatar_url");
			
			this.json = json;
		}catch(Exception e){
			e.printStackTrace();
			return;
		}
	}

	public static Feed create_or_update(String json){
		Feed newest_feed = new Feed(json);
		Feed old_feed = find(newest_feed.feed_id);
		if(old_feed == null){
			newest_feed.create();
		}else if(newest_feed.updated_at > old_feed.updated_at){
			newest_feed.update();
		}
		return newest_feed;
	}

	private void update() {
		SQLiteDatabase db = get_write_db();
		ContentValues values = new ContentValues();
		values.put(Constants.TABLE_FEEDS__JSON,this.json);
		values.put(Constants.TABLE_FEEDS__UPDATED_AT,this.updated_at);
		db.update(Constants.TABLE_FEEDS, values,Constants.TABLE_FEEDS__ID + " = "+ this.feed_id,null);
		db.close();
	}

	private void create() {
		SQLiteDatabase db = get_write_db();
		ContentValues values = new ContentValues();
		values.put(Constants.TABLE_FEEDS__ID,this.feed_id);
		values.put(Constants.TABLE_FEEDS__JSON,this.json);
		values.put(Constants.TABLE_FEEDS__UPDATED_AT,this.updated_at);
		values.put(Constants.TABLE_FEEDS__USER_ID,this.user_id);
		db.insert(Constants.TABLE_FEEDS,null, values);
		db.close();
	}

	private static Feed find(int feed_id) {
		SQLiteDatabase db = get_read_db();
		Cursor cursor = db.query(Constants.TABLE_FEEDS,
				new String[]{
								Constants.TABLE_FEEDS__JSON
							}, 
							Constants.TABLE_FEEDS__ID + " = "+feed_id, null, null, null,null);
		boolean has = cursor.moveToFirst();
		db.close();
		if(has){
			String json = cursor.getString(0);
			return new Feed(json);			
		}else{
			return null;
		}
	}
	
	public static ArrayList<Feed> build_list_by_json(String json) {
		ArrayList<Feed> feeds = new ArrayList<Feed>();
		try {
			JSONArray json_arr = new JSONArray(json);
			for (int i = 0; i < json_arr.length(); i++) {
				JSONObject json_obj = (JSONObject)json_arr.get(i);
				feeds.add(new Feed(json_obj.toString()));
			}
			return feeds;
		} catch (Exception e) {
			e.printStackTrace();
			return feeds;
		}
	}
	
	private static ArrayList<String> json_array_to_array_list(JSONArray json_array)
			throws JSONException {
		ArrayList<String> list = new ArrayList<String>();
		for (int i = 0; i < json_array.length(); i++) {
			String url = (String)json_array.get(i);
			list.add(url);
		}
		return list;
	}

	private static SQLiteDatabase get_write_db(){
		MindpinDBHelper md = new MindpinDBHelper(MindpinApplication.context, Constants.DATABASE_NAME,
				null, Constants.DATABASE_VERSION);
		return md.getWritableDatabase();
	}
	
	private static SQLiteDatabase get_read_db(){
		MindpinDBHelper md = new MindpinDBHelper(MindpinApplication.context, Constants.DATABASE_NAME,
				null, Constants.DATABASE_VERSION);
		return md.getReadableDatabase();
	}
}
