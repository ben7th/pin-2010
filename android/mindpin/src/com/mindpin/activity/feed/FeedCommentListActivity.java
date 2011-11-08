package com.mindpin.activity.feed;

import java.util.ArrayList;
import android.content.Intent;
import android.os.Bundle;
import android.view.ContextMenu;
import android.view.MenuItem;
import android.view.MenuItem.OnMenuItemClickListener;
import android.view.View;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.View.OnCreateContextMenuListener;
import android.widget.AdapterView.AdapterContextMenuInfo;
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
				ListView list = (ListView)findViewById(R.id.feed_comment_list);
				bind_list_adapter(list,feed_comments);
				bind_list_item_long_click_event(list);
			}
		}.execute(feed_id);
	}
	
	private void bind_list_item_long_click_event(ListView list) {
		list.setOnCreateContextMenuListener(new OnCreateContextMenuListener() {
			@Override
			public void onCreateContextMenu(ContextMenu menu, View v,
					ContextMenuInfo menuInfo) {
				AdapterContextMenuInfo info = (AdapterContextMenuInfo)menuInfo;
				ListView list_view = (ListView)v;
				FeedCommentListAdapter adapter = (FeedCommentListAdapter)list_view.getAdapter();
				FeedComment feed_comment = (FeedComment)adapter.getItem(info.position);
				
				menu.setHeaderTitle(feed_comment.content);
				// 增加回复评论的菜单项和点击事件
				add_reply_comment_meun_item(menu,feed_comment.comment_id+"");
				// 增加删除评论的菜单项和点击事件
				add_destroy_comment_menu_item(menu,feed_comment,adapter,info.position);
			}

			private void add_destroy_comment_menu_item(ContextMenu menu,
					final FeedComment feed_comment, final FeedCommentListAdapter adapter, final int position) {
				int current_user_id = AccountManager.current_user().user_id;
				if(current_user_id == feed_comment.comment_creator_id ||
						current_user_id == feed_comment.feed_creator_id){
					MenuItem item2 = menu.add("删除评论");
					item2.setOnMenuItemClickListener(new OnMenuItemClickListener() {
						@Override
						public boolean onMenuItemClick(MenuItem item) {
							destroy_comment(feed_comment.comment_id+"",adapter,position);
							return false;
						}
					});
				}
			}

			private void add_reply_comment_meun_item(ContextMenu menu,final String comment_id) {
				MenuItem item1 = menu.add("回复评论");
				item1.setOnMenuItemClickListener(new OnMenuItemClickListener() {
					@Override
					public boolean onMenuItemClick(MenuItem item) {
						Intent intent = new Intent(getApplicationContext(),SendFeedCommentActivity.class);
						intent.putExtra(SendFeedCommentActivity.EXTRA_NAME_COMMENT_ID,comment_id);
						FeedCommentListActivity.this.startActivity(intent);
						return false;
					}
				});						
			}
		});
	}
	
	private void bind_list_adapter(ListView list, ArrayList<FeedComment> feed_comments) {
		FeedCommentListAdapter adapter = new FeedCommentListAdapter(feed_comments);
		list.setAdapter(adapter);
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
