package com.mindpin.activity.feed;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.ArrayList;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.HeaderViewListAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import com.mindpin.R;
import com.mindpin.Logic.Http;
import com.mindpin.activity.collection.FeedDetailActivity;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.base.task.MindpinAsyncTask;
import com.mindpin.database.Feed;
import com.mindpin.receiver.BroadcastReceiverConstants;
import com.mindpin.widget.FeedListAdapter;

public class FeedListActivity extends MindpinBaseActivity {
	private FeedListAdapter adapter;
	private SynImageBroadcastReceiver syn_image_broadcast_receiver = new SynImageBroadcastReceiver();

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.feed_home_timeline);
		registerReceiver(syn_image_broadcast_receiver, new IntentFilter(BroadcastReceiverConstants.ACTION_SYN_FEED_HOME_LINE_IMAGE));

		final ListView feed_list_lv = (ListView) findViewById(R.id.feed_list);
        View loadMoreView = getLayoutInflater().inflate(R.layout.list_more_button, null);  
        View loadMoreButton = loadMoreView.findViewById(R.id.list_more_button);
        final ProgressBar loading = (ProgressBar)loadMoreView.findViewById(R.id.list_more_button_loading);
        loadMoreButton.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				new MindpinAsyncTask<String, Void, Void>(){
					public void on_start() {
						loading.setVisibility(View.VISIBLE);
					}
					
					@Override
					public Void do_in_background(String... params)
							throws Exception {
						adapter.load_more_data();
						return null;
					}

					@Override
					public void on_success(Void result) {
						loading.setVisibility(View.GONE);
					};
					
					public boolean on_unknown_exception() {
						return false;
					};
				}.execute();
			}
		});
        feed_list_lv.addFooterView(loadMoreView);
		
		new MindpinAsyncTask<String, Void, ArrayList<Feed>>(this, "’˝‘⁄‘ÿ»Î°≠") {
			@Override
			public ArrayList<Feed> do_in_background(String... params)
					throws Exception {
				return Http.get_home_timeline_feeds(-1);
			}

			@Override
			public void on_success(ArrayList<Feed> feeds) {
				adapter = new FeedListAdapter(FeedListActivity.this,
						feeds);
				feed_list_lv.setAdapter(adapter);
				feed_list_lv.setOnItemClickListener(new OnItemClickListener() {
					public void onItemClick(AdapterView<?> arg0, View arg1,
							int arg2, long arg3) {
						TextView tv = (TextView) arg1
								.findViewById(R.id.feed_id);
						String feed_id = (String) tv.getText();
						Intent intent = new Intent(FeedListActivity.this,
								FeedDetailActivity.class);
						intent.putExtra(FeedDetailActivity.EXTRA_NAME_FEED_ID,
								feed_id);
						FeedListActivity.this.startActivity(intent);
					}
				});
			}
		}.execute();

	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		unregisterReceiver(syn_image_broadcast_receiver);
	}
	
	class SynImageBroadcastReceiver extends BroadcastReceiver{
		@Override
		public void onReceive(Context context, Intent intent) {
			try {
				String image_url = intent.getStringExtra("image_url");
				String image_path = intent.getStringExtra("image_cache_path");
				
				File cache_file = new File(image_path);	
				FileInputStream is = new FileInputStream(cache_file);
				Bitmap mBitmap = BitmapFactory.decodeStream(is);
				if(mBitmap == null){
					cache_file.delete();
				}else{
					ImageView iv = adapter.get_image_view(image_url);
					if(iv != null){
						iv.setImageBitmap(mBitmap);
					}
				}
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			}
		}
	}
}
