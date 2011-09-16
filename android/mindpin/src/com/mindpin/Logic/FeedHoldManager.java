package com.mindpin.Logic;

import java.util.ArrayList;

import android.content.Context;

import com.mindpin.Logic.Http.IntentException;
import com.mindpin.database.FeedHold;
import com.mindpin.utils.BaseUtils;

public class FeedHoldManager {

	public static void save_feed_hold(Context context,String title, String content,
			ArrayList<String> images, ArrayList<Integer> select_collection_ids) {
		
		String select_collection_ids_str = 
				BaseUtils.integer_list_to_string(select_collection_ids);
		String images_str = 
				BaseUtils.string_list_to_string(images);
		
		FeedHold fh = new FeedHold(title,content,images_str,select_collection_ids_str);
		fh.insert_to_db(context);
	}
	
	public static void send_feed_holds(Context context) throws IntentException{
		ArrayList<FeedHold> fhs = FeedHold.get_feed_holds(context);
		for (FeedHold feedHold : fhs) {
			String title = feedHold.title;
			String content = feedHold.content;
			String image_paths_str = feedHold.image_paths;
			String select_collection_ids_str = feedHold.select_collection_ids;
			ArrayList<String> image_paths = BaseUtils.string_to_string_list(image_paths_str);
			ArrayList<Integer> select_collection_ids = BaseUtils.string_to_integer_list(select_collection_ids_str);
			
			boolean res = Http.send_feed(title, content, image_paths,
					select_collection_ids);
			if (res) {
				FeedHold.destroy(context, feedHold.id);
			}
		}
	}
}
