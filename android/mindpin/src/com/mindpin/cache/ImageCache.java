package com.mindpin.cache;

import java.io.File;
import java.net.URI;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.widget.ImageView;

import com.mindpin.application.MindpinApplication;
import com.mindpin.base.utils.FileDirs;
import com.mindpin.cache.image.BitmapDownloaderTask;

public class ImageCache {
	
	
	
	// 尝试在传入的view上载入指定的url的图片
	final static public void load_cached_image(String image_url, ImageView image_view){
		File cache_file = ImageCache.get_cache_file(image_url);
		
		if(null == cache_file || !cache_file.exists()){
			ImageCacheSoftRefSingleton.put_in_waiting_map(image_url, image_view);
			//send_broadcast(image_url);
			download(image_url, image_view);
		}else{
		 	ImageCacheSoftRefSingleton.set_bitmap_to_imageview(cache_file, image_view);
		}
	}
	
	// 调用asyncTask下载图片
	final static private void download(String image_url, ImageView image_view) {
//		BitmapDownloaderTask task = new BitmapDownloaderTask(image_view);
//		task.execute(image_url);
		
		if (cancelPotentialDownload(image_url, image_view)) {
			BitmapDownloaderTask task = new BitmapDownloaderTask(image_view);
			DownloadedDrawable downloadedDrawable = new DownloadedDrawable(task);
			image_view.setImageDrawable(downloadedDrawable);
			task.execute(image_url);
		}
	}
	
	private static boolean cancelPotentialDownload(String image_url, ImageView image_view) {
		BitmapDownloaderTask bitmapDownloaderTask = getBitmapDownloaderTask(image_view);

		if (bitmapDownloaderTask != null) {
			String bitmapUrl = bitmapDownloaderTask.image_url;
			
			if ((bitmapUrl == null) || (!bitmapUrl.equals(image_url))) {
				bitmapDownloaderTask.cancel(true);
			} else {
				// The same URL is already being downloaded.
				return false;
			}
		}
		return true;
	}
	
	private static BitmapDownloaderTask getBitmapDownloaderTask(ImageView image_view) {
		if (image_view != null) {
			Drawable drawable = image_view.getDrawable();
			if (drawable instanceof DownloadedDrawable) {
				DownloadedDrawable downloadedDrawable = (DownloadedDrawable) drawable;
				return downloadedDrawable.getBitmapDownloaderTask();
			}
		}
		return null;
	}
	
	
	// 发送载入图片的广播
	final static private void send_broadcast(String image_url){
		Intent intent = new Intent("com.mindpin.action.cache_image");
		intent.putExtra("image_url", image_url);
		MindpinApplication.context.sendBroadcast(intent);
	}
	
	// 发出去的广播被处理完之后，会产生一个回应的广播，被这里的receiver接收
	public static SynImageBroadcastReceiver syn_image_broadcast_receiver = new SynImageBroadcastReceiver();
	final static class SynImageBroadcastReceiver extends BroadcastReceiver{
		@Override
		public void onReceive(Context context, Intent intent) {
			String image_url = intent.getStringExtra("image_url");
			ImageView image_view = ImageCacheSoftRefSingleton.get_restored_image_view(image_url);
			
			if(null != image_view){
				File cache_file = ImageCache.get_cache_file(image_url);
				ImageCacheSoftRefSingleton.set_bitmap_to_imageview(cache_file, image_view);
			}
		}
	}
	
	
	// 根据图像url，获取本地的磁盘缓存文件路径
	// 规则是：
	// www.mindpin.com/aa/bb/cc.jpg
	// ->
	// /mindpin/cache/downloaded_image/ uri.hashCode()+".cache"
	public static File get_cache_file(String image_url) {
		try {
			URI uri = new URI(image_url);
			String filename = uri.hashCode() + ".cache";
			File cache_file = new File(
					FileDirs.mindpin_downloaded_image_cache_dir(), filename);

			return cache_file;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
}
