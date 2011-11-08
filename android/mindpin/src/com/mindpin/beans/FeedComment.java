package com.mindpin.beans;

import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONObject;
import com.mindpin.base.utils.BaseUtils;

public class FeedComment {
	public int comment_id;
	public String content;
	public long created_at;
	public String user_name;
	public String user_logo_url;
	public int feed_creator_id;
	public int comment_creator_id;

	public FeedComment(int comment_id, String content, long created_at,
			String user_name, String user_logo_url, int comment_creator_id, int feed_creator_id) {
		this.comment_id = comment_id;
		this.content = content;
		this.created_at = created_at;
		this.user_name = user_name;
		this.user_logo_url = user_logo_url;
		this.comment_creator_id = comment_creator_id;
		this.feed_creator_id = feed_creator_id;
	}

	public static ArrayList<FeedComment> build_list_by_json(String response_text) {
		ArrayList<FeedComment> list = new ArrayList<FeedComment>();
		try {
			JSONArray array = new JSONArray(response_text);
			for (int i = 0; i < array.length(); i++) {
				JSONObject json = array.getJSONObject(i);
				int id = json.getInt("id");
				String content = json.getString("content");
				long created_at = BaseUtils.parse_iso_time_string_to_long(json.getString("created_at"));
				JSONObject user = json.getJSONObject("user");
				String user_name = user.getString("name");
				String user_logo_url = user.getString("avatar_url");
				
				int comment_creator_id = user.getInt("id");
				int feed_creator_id = json.getJSONObject("feed").getJSONObject("user").getInt("id");
				
				
				list.add(new FeedComment(id,content,created_at,user_name,user_logo_url,comment_creator_id,feed_creator_id));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

}
