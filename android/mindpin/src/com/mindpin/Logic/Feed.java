package com.mindpin.Logic;

import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class Feed {
	public String getId() {
		return id;
	}

	public String getTitle() {
		return title;
	}

	public String getDetail() {
		return detail;
	}

	public ArrayList<String> getPhotos() {
		return photos;
	}

	public String getCreator_name() {
		return creator_name;
	}

	public String getCreator_logo_url() {
		return creator_logo_url;
	}

	private String id;
	private String title;
	private String detail;
	private ArrayList<String> photos;
	private String creator_name;
	private String creator_logo_url;
	
	public Feed(String id2, String title2, String detail2,
			ArrayList<String> photos2, String creator_name2,
			String creator_logo_url2) {
		this.id = id2;
		this.title = title2;
		this.detail = detail2;
		this.photos = photos2;
		this.creator_name = creator_name2;
		this.creator_logo_url = creator_logo_url2;
	}

	public Feed(String id2, String title2, String detail2,
			ArrayList<String> photos2) {
		this.id = id2;
		this.title = title2;
		this.detail = detail2;
		this.photos = photos2;
	}

	public static Feed build_by_feed_detail_json(String json_str) throws JSONException{
		JSONObject feed_json = new JSONObject(json_str);
		String id = feed_json.getString("id");
		String title = feed_json.getString("title");
		String detail = feed_json.getString("detail");
		JSONArray photos_json = feed_json.getJSONArray("photos_large");
		ArrayList<String> photos = new ArrayList<String>();
		for (int i = 0; i < photos_json.length(); i++) {
			String url = (String)photos_json.get(i);
			photos.add(url);
		}
		JSONObject user = feed_json.getJSONObject("user");
		String creator_name = user.getString("name");
		String creator_logo_url = user.getString("avatar_url");
		Feed feed = new Feed(id,title,detail,photos,creator_name,creator_logo_url);
		return feed;
	}
	
	public static ArrayList<Feed> build_by_collection_feeds_json(String json_str) throws JSONException{
		ArrayList<Feed> list = new ArrayList<Feed>();
		
		JSONArray feed_json_arr = new JSONArray(json_str);
		for (int i = 0; i < feed_json_arr.length(); i++) {
			JSONObject feed_json = feed_json_arr.getJSONObject(i);
			
			String id = (Integer)feed_json.get("id")+"";
			String title = (String)feed_json.get("title");
			String detail = (String)feed_json.get("detail");
			ArrayList<String> photos = new ArrayList<String>();
			
			JSONArray json_photos = (JSONArray)feed_json.get("photos_middle");
			for (int j = 0; j < json_photos.length(); j++) {
				String url = (String)json_photos.get(j);
				photos.add(url);
			}
			
			Feed feed = new Feed(id,title,detail,photos);
			list.add(feed);
		}
		
		return list;
	}
}
