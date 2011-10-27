package com.mindpin.receiver;

import java.io.File;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import org.apache.commons.io.FileUtils;
import com.mindpin.base.task.MindpinAsyncTask;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class CacheImageBroadcastReceiver extends BroadcastReceiver {

	@Override
	public void onReceive(final Context context, Intent intent) {
		final String image_url = intent.getStringExtra("image_url");
		final String image_path = intent.getStringExtra("image_cache_path");
		
		new MindpinAsyncTask<String, Integer, Void>() {

			public void on_start() {
			};

			@Override
			public Void do_in_background(String... params) throws Exception {
				File cache_file = new File(image_path);
				if(!cache_file.exists()){
					URL url = new URL(image_url);
					HttpURLConnection conn = (HttpURLConnection) url.openConnection();
					InputStream is = conn.getInputStream();
					FileUtils.copyInputStreamToFile(is, cache_file);
				}
				return null;
			}

			public void on_success(Void v) {
				Intent intent = new Intent(BroadcastReceiverConstants.ACTION_SYN_FEED_HOME_LINE_IMAGE);
				intent.putExtra("image_url", image_url);
				intent.putExtra("image_cache_path", image_path);
				context.sendBroadcast(intent);
			}
		}.execute();

	}
}
