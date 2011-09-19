package com.mindpin.Logic;

import java.util.ArrayList;
import android.content.Context;
import com.mindpin.database.FeedDraft;
import com.mindpin.utils.BaseUtils;

public class FeedDraftManager {

	public static void save_feed_draft(Context context,String title, String content,
			ArrayList<String> capture_paths, ArrayList<Integer> select_collection_ids) {
		String select_collection_ids_str = 
				BaseUtils.integer_list_to_string(select_collection_ids);
		String images_str = 
				BaseUtils.string_list_to_string(capture_paths);
		
		FeedDraft.insert(context,title,content,images_str,select_collection_ids_str);
	}

	public static void update_feed_draft(Context context,
			int feed_draft_id, String feed_title, String feed_content,
			ArrayList<String> capture_paths,
			ArrayList<Integer> select_collection_ids) {
		String select_collection_ids_str = 
				BaseUtils.integer_list_to_string(select_collection_ids);
		String images_str = 
				BaseUtils.string_list_to_string(capture_paths);
		
		FeedDraft.update(context,feed_draft_id,feed_title,feed_content,images_str,select_collection_ids_str);
	}
	
}
