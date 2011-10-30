package com.mindpin.database;

import java.text.ParseException;
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
	public int user_id;
	public String user_name;
	public String user_logo_url;
	public long updated_at;
	public String json;
	
	public Feed(int feed_id, String title, String detail,
			ArrayList<String> photos_middle, ArrayList<String> photos_large,
			int user_id, String user_name, String user_logo_url,
			long updated_at, String json) {
		this.feed_id = feed_id;
		this.title = title;
		this.detail = detail;
		this.photos_middle = photos_middle;
		this.photos_large = photos_large;
		this.user_id = user_id;
		this.user_name = user_name;
		this.user_logo_url = user_logo_url;
		this.updated_at = updated_at;
		this.json = json;
	}

	public static Feed create_or_update(String json){
		Feed newest_feed = build_by_json(json);
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
			return Feed.build_by_json(json);			
		}else{
			return null;
		}
	}
	
	
	public static Feed build_by_json(String json) {
		try {
			JSONObject json_obj = new JSONObject(json);
			String time_str = (String)json_obj.get("updated_at");
			
			int feed_id = (Integer)json_obj.get("id");
			String title = (String)json_obj.get("title");
			String detail = (String)json_obj.get("detail");
			long updated_at = BaseUtils.parse_iso_time_string_to_long(time_str);
			ArrayList<String> photos_middle = json_array_to_array_list((JSONArray) json_obj
					.get("photos_middle"));
			ArrayList<String> photos_large = json_array_to_array_list((JSONArray) json_obj
					.get("photos_large"));
			JSONObject user = (JSONObject)json_obj.get("user");
			int user_id = (Integer)user.getInt("id");
			String user_name = (String)user.get("name");
			String user_logo_url = (String)user.get("avatar_url");
			Feed feed = new Feed(feed_id, title, detail, photos_middle,
					photos_large, user_id, user_name, user_logo_url,
					updated_at, json);
			return feed;
		} catch (JSONException e) {
			e.printStackTrace();
			return null;
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public static ArrayList<Feed> build_list_by_json(String json) {
		ArrayList<Feed> feeds = new ArrayList<Feed>();
		try {
			JSONArray json_arr = new JSONArray(json);
			for (int i = 0; i < json_arr.length(); i++) {
				JSONObject json_obj = (JSONObject)json_arr.get(i);
				String time_str = (String)json_obj.get("updated_at");
				
				int feed_id = (Integer)json_obj.get("id");
				String title = (String)json_obj.get("title");
				String detail = (String)json_obj.get("detail");
				long updated_at = BaseUtils.parse_iso_time_string_to_long(time_str);
				ArrayList<String> photos_middle = json_array_to_array_list((JSONArray) json_obj
						.get("photos_middle"));
				ArrayList<String> photos_large = json_array_to_array_list((JSONArray) json_obj
						.get("photos_large"));
				JSONObject user = (JSONObject)json_obj.get("user");
				int user_id = (Integer)user.getInt("id");
				String user_name = (String)user.get("name");
				String user_logo_url = (String)user.get("avatar_url");
				Feed feed = new Feed(feed_id, title, detail, photos_middle,
						photos_large, user_id, user_name, user_logo_url,
						updated_at, json_obj.toString());
				feeds.add(feed);
			}
			return feeds;
		} catch (JSONException e) {
			e.printStackTrace();
			return feeds;
		} catch (ParseException e) {
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
