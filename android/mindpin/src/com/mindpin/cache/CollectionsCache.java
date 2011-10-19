package com.mindpin.cache;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.mindpin.base.utils.FileDirs;

public class CollectionsCache {

	public static void save(String collections) {
		try {
			FileUtils.writeStringToFile(get_collections_file(), collections);
		}catch(IOException e){
			e.printStackTrace();
		}
	}
	
	public static void destroy(){
		File file = get_collections_file();
		file.delete();
	}
	
	public static ArrayList<HashMap<String, Object>> get_collection_list(){
		ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String,Object>>();
		try {
			String json_str = IOUtils.toString(new FileInputStream(get_collections_file()));
			list = build_list_by_json(json_str);
			return list;
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return list;
		} catch (IOException e) {
			e.printStackTrace();
			return list;
		}
	}
	
	public static ArrayList<HashMap<String, Object>> build_list_by_json(String json_str){
		ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String,Object>>();
		try {
			JSONArray collection_list_ja = new JSONArray(json_str);
			
			for (int i = 0; i < collection_list_ja.length(); i++) {
				JSONObject collection_json = collection_list_ja.getJSONObject(i);
				JSONObject collection_attrs = (JSONObject) collection_json.get("collection");
				HashMap<String, Object> map = new HashMap<String, Object>();
				map.put("id", collection_attrs.getInt("id"));
				map.put("title", collection_attrs.getString("title"));
				list.add(map);
			}
			return list;
		} catch (JSONException e) {
			e.printStackTrace();
			return list;
		}
	}

	private static File get_collections_file(){
		return new File(FileDirs.MINDPIN_CACHE_DIR, "collections.json");
	}

}
