package com.mindpin.activity.feed;

import java.util.ArrayList;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
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
		bind_list_item_click_event();
	}

	private void bind_list_item_click_event() {
		list.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				show_context_menu_dialog(position);
			}
		});
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
		new MindpinAsyncTask<Void, Void, ArrayList<FeedComment>>(this,"正在载入...") {
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
	
	private void show_context_menu_dialog(int position){
		final FeedComment feed_comment = (FeedComment)adapter.getItem(position);
		Builder builder = new AlertDialog.Builder(this);
		final String[] items = new String[]{"回复评论","转到主题"};
		builder.setTitle("评论");
		builder.setItems(items,new DialogInterface.OnClickListener(){
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case 0:
					reply_comment(feed_comment);
					break;
				case 1:
					redirect_to_feed(feed_comment);
					break;
				}
			}
		});
		builder.show();
	}
	
	private void reply_comment(FeedComment feed_comment) {
		Intent intent = new Intent(getApplicationContext(),SendFeedCommentActivity.class);
		intent.putExtra(SendFeedCommentActivity.EXTRA_NAME_COMMENT_ID,feed_comment.comment_id+"");
		ReceivedCommentListActivity.this.startActivity(intent);
	}
	
	private void redirect_to_feed(FeedComment feed_comment) {
		Intent intent = new Intent(getApplicationContext(),
				FeedDetailActivity.class);
		intent.putExtra(FeedDetailActivity.EXTRA_NAME_FEED_ID, feed_comment.feed_id+"");
		ReceivedCommentListActivity.this.startActivity(intent);
	}
	
}
