package com.mindpin.beans;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class Following {

	public int user_id;
	public String name;
	public String sign;
	public boolean v2_activate;
	public boolean following;
	public String avatar_url;

	public Following(int user_id, String name, String sign,
			boolean v2_activate, boolean following, String avatar_url) {
		
		this.user_id = user_id;
		this.name = name;
		this.sign = sign;
		this.v2_activate = v2_activate;
		this.following = following;
		this.avatar_url = avatar_url;
	}

	public static ArrayList<Following> build_list_by_json(String response_text) {
		ArrayList<Following> list = new ArrayList<Following>();
		
		try {
			JSONArray json_array = new JSONArray(response_text);
			for (int i = 0; i < json_array.length(); i++) {
				JSONObject json_obj = json_array.getJSONObject(i);
				String avatar_url = json_obj.getString("avatar_url");
				boolean following = json_obj.getBoolean("following");
				boolean v2_activate = json_obj.getBoolean("v2_activate");
				String sign = json_obj.getString("sign");
				String name = json_obj.getString("name");
				int user_id = json_obj.getInt("id");
				Following follo = new Following(user_id,name,sign,v2_activate,following,avatar_url);
				list.add(follo);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		
		return list;
	}

}
