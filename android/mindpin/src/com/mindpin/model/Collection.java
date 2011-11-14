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
	
	// һ��ÿ��model��������ͷ
	final public static Collection NIL_COLLECTION = new Collection();
	private Collection(){
		set_nil();
	}
	
	private Collection(String json_str) throws JSONException {
		JSONObject json = new JSONObject(json_str);
		
		this.collection_id = json.getInt("id");
		this.title         = json.getString("title");
	}
	
	public static Collection build(String json_str) throws JSONException{
		if(json_str == "null"){
			return Collection.NIL_COLLECTION;
		}else{
			return new Collection(json_str);
		}
	}

	// һ��Ҳ��һ�������ġ����족 List �ĺ���
	public static List<Collection> build_list_by_json(String json_str) throws JSONException {
		List<Collection> list = new ArrayList<Collection>();
		JSONArray collection_list_ja = new JSONArray(json_str);
		
		for (int i = 0; i < collection_list_ja.length(); i++) {
			String collection_json_str = collection_list_ja.getString(i);
			list.add(Collection.build(collection_json_str));
		}
		return list;
	}
}
