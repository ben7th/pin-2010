package com.mindpin.cache;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.lang.ref.SoftReference;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashMap;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.widget.ImageView;

import com.mindpin.application.MindpinApplication;
import com.mindpin.base.utils.FileDirs;

public class FeedImageCache {
	private static HashMap<String, SoftReference<ImageView>> image_view_hashmap = new HashMap<String,SoftReference<ImageView>>();
	
	final static ImageView get_image_view(String image_url){
		SoftReference<ImageView> soft_ref = image_view_hashmap.get(image_url);
		return null == soft_ref ? null : soft_ref.get();
	}
	
	final static public void load_cached_image(String image_url, ImageView image_view){
		image_view_hashmap.put(image_url, new SoftReference<ImageView>(image_view));
		Intent intent = new Intent("com.mindpin.action.cache_image");
		intent.putExtra("image_url", image_url);
		MindpinApplication.context.sendBroadcast(intent);
	}
	
	// 根据图像url，获取本地的磁盘缓存文件路径
	// 规则是：
	// www.mindpin.com/aa/bb/cc.jpg
	// ->
	// /mindpin/cache/www_mindpin_com/aa/bb/cc.jpg
	public static File get_cache_file(String image_url) {
		try {
			URI uri = new URI(image_url);

			String filename = uri.hashCode() + ".cache";

			File cache_file = new File(
					FileDirs.mindpin_downloaded_image_cache_dir(), filename);
			
			return cache_file;
		} catch (URISyntaxException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public static SynImageBroadcastReceiver syn_image_broadcast_receiver = new SynImageBroadcastReceiver();
	
	final static class SynImageBroadcastReceiver extends BroadcastReceiver{
		@Override
		public void onReceive(Context context, Intent intent) {
			try {
				String image_url = intent.getStringExtra("image_url");
				File cache_file = FeedImageCache.get_cache_file(image_url);
				FileInputStream stream = new FileInputStream(cache_file);
				Bitmap img_bitmap = BitmapFactory.decodeStream(stream);
				
				if(null == img_bitmap){
					cache_file.delete();
				}else{
					ImageView image_view = get_image_view(image_url);
					if(null != image_view){
						image_view.setImageBitmap(img_bitmap);
					}
				}
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			}
		}
	}
}
