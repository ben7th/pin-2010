package com.mindpin.model;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.mindpin.model.base.BaseModel;

public class Collection extends BaseModel {
	public int collection_id;
	public String title;
	
	// 一般每个model都这样开头
	final public static Collection NIL_COLLECTION = new Collection();
	private Collection(){
		set_nil();
	}
	
	// 公开构造函数只保留根据 json_str 构造对象的函数
	public Collection(String json_str) throws JSONException {
		JSONObject json = new JSONObject(json_str);
		
		this.collection_id = json.getInt("id");
		this.title         = json.getString("title");
	}

	// 一般也有一个这样的“构造” List 的函数
	public static List<Collection> build_list_by_json(String json_str) throws JSONException {
		List<Collection> list = new ArrayList<Collection>();
		JSONArray collection_list_ja = new JSONArray(json_str);
		
		for (int i = 0; i < collection_list_ja.length(); i++) {
			String collection_json_str = collection_list_ja.getString(i);
			Collection collection = new Collection(collection_json_str);
			list.add(collection);
		}
		return list;
	}
}
