package com.mindpin.Logic;

import java.util.ArrayList;
import android.content.Context;
import com.mindpin.database.FeedDraft;
import com.mindpin.utils.BaseUtils;

public class FeedDraftManager {

	public static void save_feed_draft(Context context,String title, String content,
			ArrayList<String> capture_paths, ArrayList<Integer> select_collection_ids,boolean send_tsina) {
		String select_collection_ids_str = 
				BaseUtils.integer_list_to_string(select_collection_ids);
		String images_str = 
				BaseUtils.string_list_to_string(capture_paths);
		
		FeedDraft.insert(context,title,content,images_str,select_collection_ids_str,send_tsina);
	}

	public static void update_feed_draft(Context context,
			int feed_draft_id, String feed_title, String feed_content,
			ArrayList<String> capture_paths,
			ArrayList<Integer> select_collection_ids,boolean send_tsina) {
		String select_collection_ids_str = 
				BaseUtils.integer_list_to_string(select_collection_ids);
		String images_str = 
				BaseUtils.string_list_to_string(capture_paths);
		
		FeedDraft.update(context,feed_draft_id,feed_title,feed_content,images_str,select_collection_ids_str,send_tsina);
	}
	
	public static ArrayList<FeedDraft> get_feed_drafts(Context context){
		return FeedDraft.get_feed_drafts(context);
	}
	
	public static boolean has_feed_draft(Context context){
		return FeedDraft.get_count(context) != 0;
	}

	public static boolean has_change(Context context,
			int feed_draft_id, String feed_title, String feed_content,
			ArrayList<String> capture_paths,
			ArrayList<Integer> select_collection_ids,boolean send_tsina) {
		FeedDraft fd = FeedDraft.find(context, feed_draft_id);
		boolean title_change = (!fd.title.equals(feed_title));
		boolean content_change = (!fd.content.equals(feed_content));
		boolean collections_change = (!BaseUtils.integer_list_to_string(select_collection_ids).equals(fd.select_collection_ids));
		boolean send_tsina_change = (fd.send_tsina != send_tsina);
		boolean image_change = (!BaseUtils.string_list_to_string(capture_paths).equals(fd.image_paths));
		return (title_change || content_change || collections_change || image_change || send_tsina_change);
	}
	
}
