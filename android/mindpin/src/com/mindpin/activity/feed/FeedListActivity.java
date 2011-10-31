package com.mindpin.activity.feed;

import java.util.ArrayList;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.mindpin.R;
import com.mindpin.Logic.Http;
import com.mindpin.activity.collection.FeedDetailActivity;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.base.task.MindpinAsyncTask;
import com.mindpin.database.Feed;
import com.mindpin.widget.FeedListAdapter;

public class FeedListActivity extends MindpinBaseActivity {
	private FeedListAdapter adapter;
	
	
	private ListView feed_list;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.feed_home_timeline);


		feed_list = (ListView) findViewById(R.id.feed_list);
        
		bind_load_more_button_event();
		load_feeds_data();
	}
	
	private void bind_load_more_button_event(){
        View load_more_view = getLayoutInflater().inflate(R.layout.list_more_button, null);  
        View load_more_button = load_more_view.findViewById(R.id.list_more_button);
		final ProgressBar loading_progress = (ProgressBar)load_more_view.findViewById(R.id.list_more_button_loading);
		
        load_more_button.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				new MindpinAsyncTask<String, Void, Void>(){
					public void on_start() {
						loading_progress.setVisibility(View.VISIBLE);
					}
					
					@Override
					public Void do_in_background(String... params)
							throws Exception {
						adapter.load_more_data();
						return null;
					}

					@Override
					public void on_success(Void result) {
						loading_progress.setVisibility(View.GONE);
					};
					
					public boolean on_unknown_exception() {
						return false;
					};
				}.execute();
			}
		});
        
        feed_list.addFooterView(load_more_view);
	}
	
	private void load_feeds_data() {
		new MindpinAsyncTask<String, Void, ArrayList<Feed>>(this, "’˝‘⁄‘ÿ»Î°≠") {
			@Override
			public ArrayList<Feed> do_in_background(String... params)
					throws Exception {
				return Http.get_home_timeline_feeds(-1);
			}

			@Override
			public void on_success(ArrayList<Feed> feeds) {
				adapter = new FeedListAdapter(feeds);
				feed_list.setAdapter(adapter);
				feed_list.setOnItemClickListener(new OnItemClickListener() {
					public void onItemClick(AdapterView<?> arg0, View arg1,
							int arg2, long arg3) {
						TextView text_view = (TextView) arg1
								.findViewById(R.id.feed_id);
						String feed_id = (String) text_view.getText();

						Intent intent = new Intent(getApplicationContext(),
								FeedDetailActivity.class);
						intent.putExtra(FeedDetailActivity.EXTRA_NAME_FEED_ID,
								feed_id);
						FeedListActivity.this.startActivity(intent);
					}
				});
			}
		}.execute();
	}
	
}
