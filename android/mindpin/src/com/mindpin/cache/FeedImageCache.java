package com.mindpin.cache;

import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;

import com.mindpin.base.utils.FileDirs;
import com.mindpin.database.Feed;

public class FeedImageCache {
	public static File get_cache_file(Feed feed,String image_url){
		try {
			URI uri = new URI(image_url);
			String path = uri.getPath();
			String[] arr = path.split("/");
			String file_name = arr[4] + "_" + arr[5];
			File file = FileDirs.feed_data_dir(feed);
			File cache_file = new File(file,file_name);
		return cache_file;
		} catch (URISyntaxException e) {
			e.printStackTrace();
			return null;
		}
	}
}
