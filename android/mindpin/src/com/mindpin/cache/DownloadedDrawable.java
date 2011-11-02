package com.mindpin.cache;

import java.lang.ref.WeakReference;

import android.graphics.drawable.ColorDrawable;

import com.mindpin.cache.image.BitmapDownloaderTask;

public class DownloadedDrawable extends ColorDrawable {
	private final WeakReference<BitmapDownloaderTask> bitmapDownloaderTaskReference;
	
	public DownloadedDrawable(BitmapDownloaderTask task){
		bitmapDownloaderTaskReference = new WeakReference<BitmapDownloaderTask>(task);
	}
	
	public BitmapDownloaderTask getBitmapDownloaderTask() {
		return bitmapDownloaderTaskReference.get();
	}
}
