package com.mindpin.activity.feed;

import java.util.ArrayList;

import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ListView;
import android.widget.ProgressBar;

import com.mindpin.R;
import com.mindpin.Logic.Http;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.base.task.MindpinAsyncTask;
import com.mindpin.beans.FeedComment;
import com.mindpin.widget.adapter.ReceivedCommentListAdapter;

public class ReceivedCommentListActivity extends MindpinBaseActivity {
	private ListView list;
	private ReceivedCommentListAdapter adapter;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.received_comment_list);
		
		list = (ListView)findViewById(R.id.received_comment_list);
		
		bind_received_comment_list_event();
		bind_load_more_button_event();
	}

	private void bind_load_more_button_event() {
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
        
        list.addFooterView(load_more_view);
	}

	private void bind_received_comment_list_event() {
		new MindpinAsyncTask<Void, Void, ArrayList<FeedComment>>(this,"’˝‘⁄‘ÿ»Î...") {
			@Override
			public ArrayList<FeedComment> do_in_background(Void... params)
					throws Exception {
				return Http.received_comments();
			}

			@Override
			public void on_success(ArrayList<FeedComment> feed_comments) {
				adapter = new ReceivedCommentListAdapter(feed_comments);
				list.setAdapter(adapter);
			}
		}.execute();
	}
	
}
