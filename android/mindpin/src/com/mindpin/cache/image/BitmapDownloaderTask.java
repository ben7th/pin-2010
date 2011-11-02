package com.mindpin.cache.image;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

import org.apache.commons.io.FileUtils;

import com.mindpin.cache.ImageCache;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.widget.ImageView;

public class BitmapDownloaderTask extends AsyncTask<String, Integer, Bitmap> {
	public String image_url;
	private final WeakReference<ImageView> imageViewReference;
	
	public BitmapDownloaderTask(ImageView imageView){
		imageViewReference = new WeakReference<ImageView>(imageView);
	}
	
	@Override
	protected Bitmap doInBackground(String... params) {
		try {
			String image_url = params[0];
			
			File cache_file = ImageCache.get_cache_file(image_url);
			if(null != cache_file && !cache_file.exists()){
				URL url = new URL(image_url);
				HttpURLConnection conn = (HttpURLConnection) url.openConnection();
				InputStream is = conn.getInputStream();
				FileUtils.copyInputStreamToFile(is, cache_file);
				is.close();
			}
			
			return null;
		} catch (MalformedURLException e) {
			e.printStackTrace();
			return null;
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
		
	}
	
	protected void onPostExecute(Bitmap bitmap) {
		if(isCancelled()){
			bitmap = null;
		}
		
		if(imageViewReference != null){
			ImageView imageView = imageViewReference.get();
			if(imageView != null){
				imageView.setImageBitmap(bitmap);
			}
		}
	};

}
