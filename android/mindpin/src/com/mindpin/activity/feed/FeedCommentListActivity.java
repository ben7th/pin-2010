package com.mindpin.activity.feed;

import java.util.ArrayList;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import com.mindpin.R;
import com.mindpin.Logic.AccountManager;
import com.mindpin.Logic.Http;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.base.task.MindpinAsyncTask;
import com.mindpin.beans.FeedComment;
import com.mindpin.widget.adapter.FeedCommentListAdapter;

public class FeedCommentListActivity extends MindpinBaseActivity {
	public static final String EXTRA_NAME_FEED_ID = "feed_id";
	private ListView list;
	private FeedCommentListAdapter adapter;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.feed_comment_list);
		
		bind_feed_comment_list_event();
	}

	private void bind_feed_comment_list_event() {
		String feed_id = getIntent().getStringExtra(EXTRA_NAME_FEED_ID);
		new MindpinAsyncTask<String, Void, ArrayList<FeedComment>>(this,"正在载入..."){

			@Override
			public ArrayList<FeedComment> do_in_background(String... params)
					throws Exception {
				String feed_id = params[0];
				return Http.get_feed_comments(feed_id);
			}

			@Override
			public void on_success(ArrayList<FeedComment> feed_comments) {
				list = (ListView)findViewById(R.id.feed_comment_list);
				adapter = new FeedCommentListAdapter(feed_comments);
				list.setAdapter(adapter);
				list.setOnItemClickListener(new OnItemClickListener() {
					@Override
					public void onItemClick(AdapterView<?> parent, View view,
							int position, long id) {
						show_context_menu_dialog(position);
					}
				});
			}
		}.execute(feed_id);
	}
	
	private void show_context_menu_dialog(final int position){
		Builder builder = new AlertDialog.Builder(this);
		
		final FeedComment feed_comment = (FeedComment)adapter.getItem(position);
		int current_user_id = AccountManager.current_user().user_id;
		if(current_user_id == feed_comment.comment_creator_id ||
				current_user_id == feed_comment.feed_creator_id){
			
			build_has_delete_context_menu_dialog(position, builder, feed_comment);
		}else{
			build_no_delete_context_menu_dialog(builder, feed_comment);
		}
		
		builder.show();
	}

	private void build_no_delete_context_menu_dialog(Builder builder,
			final FeedComment feed_comment) {
		final String[] items = new String[]{"回复评论"};
		builder.setTitle("评论");
		builder.setItems(items,new DialogInterface.OnClickListener(){
			@Override
			public void onClick(DialogInterface dialog, int which) {
				reply_comment(feed_comment);
			}
		});
	}

	private void build_has_delete_context_menu_dialog(final int position,
			Builder builder, final FeedComment feed_comment) {
		final String[] items = new String[]{"回复评论","删除评论"};
		builder.setTitle("评论");
		builder.setItems(items,new DialogInterface.OnClickListener(){
			@Override
			public void onClick(DialogInterface dialog, int which) {
				switch (which) {
				case 0:
					reply_comment(feed_comment);
					break;
				case 1:
					show_destroy_comment_dialog(feed_comment.comment_id+"", adapter, position);
					break;
				}
			}
		});
	}
	
	private void reply_comment(FeedComment feed_comment) {
		Intent intent = new Intent(getApplicationContext(),SendFeedCommentActivity.class);
		intent.putExtra(SendFeedCommentActivity.EXTRA_NAME_COMMENT_ID,feed_comment.comment_id+"");
		FeedCommentListActivity.this.startActivity(intent);
	}
	
	private void show_destroy_comment_dialog(final String comment_id, final FeedCommentListAdapter adapter, final int position) {
		Builder builder = new AlertDialog.Builder(this);
		
		builder
		.setMessage("确认删除这条评论吗？")
		.setPositiveButton(R.string.dialog_ok,
			new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog,
						int which) {
					destroy_comment(comment_id, adapter, position);
				}
			})
		.setNegativeButton(R.string.dialog_cancel, null)
		.show();
	}
	
	private void destroy_comment(String comment_id, final FeedCommentListAdapter adapter, final int position) {
		// TODO MindpinAsyncTask 第二个参数没起作用
		new MindpinAsyncTask<String, Void, Void>(
				FeedCommentListActivity.this,
				"正在删除..."
				) {
			@Override
			public Void do_in_background(
					String... params)
					throws Exception {
				String comment_id = params[0];
				Http.destroy_feed_commment(comment_id);
				return null;
			}

			@Override
			public void on_success(Void result) {
				adapter.destroy_item(position);
			}
		}.execute(comment_id);
	}
	
}
