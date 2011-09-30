package com.mindpin;

import java.util.HashMap;
import java.util.List;

import com.mindpin.Logic.AccountManager.AuthenticateException;
import com.mindpin.Logic.Http;
import com.mindpin.Logic.Http.IntentException;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;

public class CollectionFeedListActivity extends Activity {
	public static final String EXTRA_COLLECTION_ID = "collection_id";
	protected static final String EXTRA_COLLECTION_TITLE = "collection_title";
	public static final String EXTRA_IS_DESTROY_COLLECTION = "is_destroy_collection";
	
	public static final int MESSAGE_INTENT_CONNECTION_FAIL = 0;
	public static final int MESSAGE_READ_FEED_LIST_SUCCESS = 1;
	public static final int MESSAGE_DESTROY_COLLECTION_SUCCESS = 2;
	public static final int MESSAGE_DESTROY_COLLECTION_FAIL = 3;
	public static final int MESSAGE_CHANGE_COLLECTION_NAME_SUCCESS = 4;
	public static final int MESSAGE_CHANGE_COLLECTION_NAME_FAIL = 5;
	public static final int MESSAGE_AUTH_FAIL = 6;
	
	private int collection_id;
	private String collection_title;
	private ProgressDialog progress_dialog;
	private List<HashMap<String, Object>> feeds;
	private ListView feed_list_lv;
	private Handler mhandler = new Handler(){
		public void handleMessage(android.os.Message msg) {
			switch (msg.what) {
			case MESSAGE_INTENT_CONNECTION_FAIL:
				Toast.makeText(getApplicationContext(),R.string.intent_connection_fail,
						Toast.LENGTH_SHORT).show();
				break;
			case MESSAGE_READ_FEED_LIST_SUCCESS:
				SimpleAdapter sa = new SimpleAdapter(CollectionFeedListActivity.this, 
						feeds, R.layout.feed_item,
						new String[]{"id","title"}, 
						new int[]{R.id.feed_id,R.id.feed_title});
				feed_list_lv.setAdapter(sa);
				feed_list_lv.setOnItemClickListener(new OnItemClickListener() {
					public void onItemClick(AdapterView<?> arg0, View arg1,
							int arg2, long arg3) {
						TextView tv = (TextView)arg1.findViewById(R.id.feed_id);
						String feed_id = (String)tv.getText();
						Intent intent = new Intent(CollectionFeedListActivity.this,FeedDetailActivity.class);
						intent.putExtra(FeedDetailActivity.EXTRA_NAME_FEED_ID,feed_id);
						CollectionFeedListActivity.this.startActivity(intent);
					}
				});
				break;
			case MESSAGE_DESTROY_COLLECTION_SUCCESS:
				Toast.makeText(getApplicationContext(),"操作成功",
						Toast.LENGTH_SHORT).show();
				CollectionFeedListActivity.this.finish();
				break;
			case MESSAGE_DESTROY_COLLECTION_FAIL:
				Toast.makeText(getApplicationContext(),"操作失败",
						Toast.LENGTH_SHORT).show();
				break;
			case MESSAGE_CHANGE_COLLECTION_NAME_SUCCESS:
				Toast.makeText(getApplicationContext(),"操作成功",
						Toast.LENGTH_SHORT).show();
				break;
			case MESSAGE_CHANGE_COLLECTION_NAME_FAIL:
				Toast.makeText(getApplicationContext(),"操作失败",
						Toast.LENGTH_SHORT).show();
				break;
			case MESSAGE_AUTH_FAIL:
				Toast.makeText(getApplicationContext(), R.string.auth_fail_tip,
						Toast.LENGTH_SHORT).show();
				startActivity(new Intent(CollectionFeedListActivity.this,LoginActivity.class));
				CollectionFeedListActivity.this.finish();
				break;
			}
			progress_dialog.dismiss();
		};
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.collection_feed_list);
		collection_id = getIntent().getIntExtra(EXTRA_COLLECTION_ID, 0);
		collection_title = getIntent().getStringExtra(EXTRA_COLLECTION_TITLE);
		progress_dialog = ProgressDialog.show(this,
				"","正在读取数据...");
		
		feed_list_lv = (ListView)findViewById(R.id.feed_list);
		
		Thread thread = new Thread(new ReadCollectionFeedListRunnable(collection_id));
		thread.setDaemon(true);
		thread.start();
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.collection_feed_list, menu);
		return super.onCreateOptionsMenu(menu);
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case R.id.menu_delete_collection:
			progress_dialog = ProgressDialog.show(this,
					"","正在删除...");
			Thread thread = new Thread(new DestroyCollectionRunnable(collection_id));
			thread.setDaemon(true);
			thread.start();
			break;
		case R.id.menu_change_collection_name:
			show_change_collection_name_dialog();
			break;
		}
		return super.onOptionsItemSelected(item);
	}
	
	private void show_change_collection_name_dialog() {
		LayoutInflater factory = LayoutInflater
				.from(this);
		final View view = factory.inflate(R.layout.change_collection_name_dialog, null);
		EditText ctet = (EditText) view
				.findViewById(R.id.collection_title_et);
		ctet.setText(collection_title);
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setTitle("修改标题");
		builder.setView(view);
		builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				EditText ctet = (EditText) view
						.findViewById(R.id.collection_title_et);
				String title = ctet.getText().toString();
				if (title == null || "".equals(title)) {
					Toast.makeText(getApplicationContext(), "请输入标题",
							Toast.LENGTH_SHORT).show();
					return;
				}
				progress_dialog = ProgressDialog.show(
						CollectionFeedListActivity.this, "", "正在修改...");
				Thread thread = new Thread(new ChangeCollectionNameRunnable(collection_id,title));
				thread.setDaemon(true);
				thread.start();
			}
		});
		builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
			}
		});
		builder.show();
	}
	
	public class ReadCollectionFeedListRunnable implements Runnable {
		private int id;
		public ReadCollectionFeedListRunnable(int id){
			this.id = id;
		}
		@Override
		public void run() {
			try {
				feeds = Http.get_collection_feeds(id);
				mhandler.sendEmptyMessage(MESSAGE_READ_FEED_LIST_SUCCESS);
			} catch (IntentException e) {
				mhandler.sendEmptyMessage(MESSAGE_INTENT_CONNECTION_FAIL);
			} catch (AuthenticateException e) {
				mhandler.sendEmptyMessage(MESSAGE_AUTH_FAIL);
				e.printStackTrace();
			}
		}
	}
	
	
	public class DestroyCollectionRunnable implements Runnable{
		private int id;
		public DestroyCollectionRunnable(int id){
			this.id = id;
		}
		@Override
		public void run() {
			try {
				if (Http.destroy_collection(id)) {
					mhandler.sendEmptyMessage(MESSAGE_DESTROY_COLLECTION_SUCCESS);
				} else {
					mhandler.sendEmptyMessage(MESSAGE_DESTROY_COLLECTION_FAIL);
				}
			} catch (NumberFormatException e) {
				e.printStackTrace();
			} catch (IntentException e) {
				mhandler.sendEmptyMessage(MESSAGE_INTENT_CONNECTION_FAIL);
			} catch (AuthenticateException e) {
				mhandler.sendEmptyMessage(MESSAGE_AUTH_FAIL);
			}
		}
	}
	
	public class ChangeCollectionNameRunnable implements Runnable{
		private int id;
		private String title;
		
		public ChangeCollectionNameRunnable(int collection_id,
				String collection_title) {
			this.id = collection_id;
			this.title = collection_title;
		}

		@Override
		public void run() {
			try {
				if (Http.change_collection_name(id,title)) {
					mhandler.sendEmptyMessage(MESSAGE_CHANGE_COLLECTION_NAME_SUCCESS);
				} else {
					mhandler.sendEmptyMessage(MESSAGE_CHANGE_COLLECTION_NAME_FAIL);
				}
			} catch (NumberFormatException e) {
				e.printStackTrace();
			} catch (IntentException e) {
				e.printStackTrace();
				mhandler.sendEmptyMessage(MESSAGE_INTENT_CONNECTION_FAIL);
			} catch (AuthenticateException e) {
				mhandler.sendEmptyMessage(MESSAGE_AUTH_FAIL);
				e.printStackTrace();
			}
		}
		
	}
}
