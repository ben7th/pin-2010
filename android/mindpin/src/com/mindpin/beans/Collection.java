package com.mindpin.beans;

import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class Collection {
	public int collection_id;
	public String title;
	
	public Collection(int collection_id, String title) {
		this.collection_id = collection_id;
		this.title = title;
	}

	public static ArrayList<Collection> build_list_by_json(String json_str){
		ArrayList<Collection> list = new ArrayList<Collection>();
		try {
			JSONArray collection_list_ja = new JSONArray(json_str);
			
			for (int i = 0; i < collection_list_ja.length(); i++) {
				JSONObject collection_json = collection_list_ja.getJSONObject(i);
				JSONObject collection_attrs = (JSONObject) collection_json.get("collection");
				Collection collection = new Collection(collection_attrs.getInt("id"),collection_attrs.getString("title"));
				list.add(collection);
			}
			return list;
		} catch (JSONException e) {
			e.printStackTrace();
			return list;
		}
	}
}
