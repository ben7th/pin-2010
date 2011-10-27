package com.mindpin.widget;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import org.apache.commons.io.FileUtils;
import com.mindpin.cache.FeedImageCache;
import com.mindpin.database.Feed;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.widget.ImageView;

public class DownloadFeedPhotoTask extends AsyncTask<String, Integer, Bitmap>{
	private ImageView view;
	private Feed feed;
	private String photo_url;

	public DownloadFeedPhotoTask(Feed feed,String photo_url,ImageView view) {
		this.view = view;
		this.feed = feed;
		this.photo_url = photo_url;
	}

	protected Bitmap doInBackground(String... arg0) {
		return get_bitmap();
	}

	private Bitmap get_bitmap() {
		try {
			Bitmap mBitmap = get_cache_bitmap();
			if(mBitmap == null){
				File cache_file = get_cache_file();
				URL url = new URL(photo_url);
				HttpURLConnection conn = (HttpURLConnection) url.openConnection();
				InputStream is = conn.getInputStream();
				
				FileUtils.copyInputStreamToFile(is, cache_file);
				FileInputStream fis = new FileInputStream(get_cache_file());
				mBitmap = BitmapFactory.decodeStream(fis);
			}
			return mBitmap;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	private Bitmap get_cache_bitmap() {
		Bitmap mBitmap = null;
		try {
			File cache_file = get_cache_file();
			if(cache_file.exists()){
				FileInputStream is = new FileInputStream(cache_file);
				mBitmap = BitmapFactory.decodeStream(is);
				if(mBitmap == null){
					cache_file.delete();
				}
			}
			return mBitmap;
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return mBitmap;
		}
	}

	@Override
	protected void onPostExecute(Bitmap result) {
		super.onPostExecute(result);
		view.setImageBitmap(result);
	}
	
	private File get_cache_file(){
		return FeedImageCache.get_cache_file(feed, photo_url);
	}
}
