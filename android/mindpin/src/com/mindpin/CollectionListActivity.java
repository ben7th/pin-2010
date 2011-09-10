package com.mindpin;

import java.util.HashMap;
import java.util.List;
import com.mindpin.Logic.Http;
import com.mindpin.Logic.Http.IntentException;
import com.mindpin.cache.CollectionsCache;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.ContextMenu;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.MenuItem.OnMenuItemClickListener;
import android.view.View;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.View.OnClickListener;
import android.view.View.OnCreateContextMenuListener;
import android.widget.AdapterView;
import android.widget.AdapterView.AdapterContextMenuInfo;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;

public class CollectionListActivity extends Activity {
	public static final int MESSAGE_READ_COLLECTION_LIST_SUCCESS = 0;
	protected static final int MESSAGE_CREATE_COLLECTION_SUCCESS = 1;
	protected static final int MESSAGE_CREATE_COLLECTION_FAIL = 2;
	public static final int MESSAGE_DESTROY_COLLECTION_SUCCESS = 3;
	public static final int MESSAGE_DESTROY_COLLECTION_FAIL = 4;
	public static final int MESSAGE_INTENT_CONNECTION_FAIL = 5;
	private ProgressDialog progress_dialog;
	private List<HashMap<String, Object>> collections;
	private ListView collection_list_lv;
	private Button new_collection;

	private Handler mhandler = new Handler() {
		public void handleMessage(android.os.Message msg) {
			switch (msg.what) {
			case MESSAGE_INTENT_CONNECTION_FAIL:
				Toast.makeText(getApplicationContext(),
						R.string.intent_connection_fail, Toast.LENGTH_SHORT)
						.show();
				break;
			case MESSAGE_READ_COLLECTION_LIST_SUCCESS:
				build_collection_list();
				break;
			case MESSAGE_CREATE_COLLECTION_SUCCESS:
				build_collection_list();
				Toast.makeText(getApplicationContext(), "操作成功",
						Toast.LENGTH_SHORT).show();
				break;
			case MESSAGE_DESTROY_COLLECTION_SUCCESS:
				build_collection_list();
				Toast.makeText(getApplicationContext(), "操作成功",
						Toast.LENGTH_SHORT).show();
				break;
			case MESSAGE_CREATE_COLLECTION_FAIL:
				Toast.makeText(getApplicationContext(), "创建失败",
						Toast.LENGTH_SHORT).show();
				break;
			}
			progress_dialog.dismiss();
		};

		private void build_collection_list() {
			SimpleAdapter sa = new SimpleAdapter(CollectionListActivity.this,
					collections, R.layout.collection_item, new String[] { "id",
							"title" }, new int[] { R.id.collection_id,
							R.id.collection_title });
			collection_list_lv.setAdapter(sa);

			collection_list_lv
					.setOnItemClickListener(new OnItemClickListener() {
						@Override
						public void onItemClick(AdapterView<?> arg0, View arg1,
								int arg2, long arg3) {
							HashMap<String, Object> hash = collections
									.get(arg2);
							int id = (Integer) hash.get("id");
							Intent intent = new Intent(
									CollectionListActivity.this,
									CollectionFeedListActivity.class);
							intent.putExtra(
									CollectionFeedListActivity.EXTRA_COLLECTION_ID,
									id);
							startActivity(intent);
						}
					});
			CollectionListActivity.this.registerForContextMenu(collection_list_lv);
			collection_list_lv.setOnCreateContextMenuListener(new OnCreateContextMenuListener() {
				@Override
				public void onCreateContextMenu(ContextMenu menu, View v,
						ContextMenuInfo menuInfo) {
					AdapterView.AdapterContextMenuInfo info = (AdapterContextMenuInfo) menuInfo;
					View tv = info.targetView;
					TextView idv = (TextView) tv
							.findViewById(R.id.collection_id);
					final String id = (String) idv.getText();
					TextView ttv = (TextView) tv
							.findViewById(R.id.collection_title);
					menu.setHeaderTitle(ttv.getText());
					MenuItem a = menu.add("删除");
					a.setOnMenuItemClickListener(new OnMenuItemClickListener() {
						@Override
						public boolean onMenuItemClick(MenuItem item) {
							progress_dialog = ProgressDialog.show(CollectionListActivity.this, "", "正在删除...");
							Thread thread = new Thread(new DestroyCollectionRunnable(id));
							thread.setDaemon(true);
							thread.start();
							return true;
						}
					});
				}
			});
		}
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.collection_list);
		collection_list_lv = (ListView) findViewById(R.id.collection_list);
		progress_dialog = ProgressDialog.show(this, "", "正在读取数据...");

		new_collection = (Button) findViewById(R.id.new_collection);
		new_collection.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				show_new_collection_dialog();
			}
		});

		Thread thread = new Thread(new ReadCollectionListRunnable());
		thread.setDaemon(true);
		thread.start();
	}

	private void show_new_collection_dialog() {
		LayoutInflater factory = LayoutInflater
				.from(CollectionListActivity.this);
		final View view = factory.inflate(R.layout.new_collection_dialog, null);
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setTitle("新建收集册");
		builder.setView(view);
		builder.setPositiveButton("创建", new DialogInterface.OnClickListener() {
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
						CollectionListActivity.this, "", "正在创建...");
				Thread thread = new Thread(new CreateCollectionRunnable(title));
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

	public class ReadCollectionListRunnable implements Runnable {
		public void run() {
			try {
				collections = Http.get_collections();
				mhandler.sendEmptyMessage(MESSAGE_READ_COLLECTION_LIST_SUCCESS);
			} catch (IntentException e) {
				mhandler.sendEmptyMessage(MESSAGE_INTENT_CONNECTION_FAIL);
				e.printStackTrace();
			}
		}
	}

	public class CreateCollectionRunnable implements Runnable {
		private String title;

		public CreateCollectionRunnable(String title) {
			this.title = title;
		}

		public void run() {
			try {
				boolean success;
				success = Http.create_collection(title);
				if (success) {
					collections = CollectionsCache.get_collection_list();
					mhandler.sendEmptyMessage(MESSAGE_CREATE_COLLECTION_SUCCESS);
				} else {
					mhandler.sendEmptyMessage(MESSAGE_CREATE_COLLECTION_FAIL);
				}
			} catch (IntentException e) {
				mhandler.sendEmptyMessage(MESSAGE_INTENT_CONNECTION_FAIL);
			}
		}
	}
	
	public class DestroyCollectionRunnable implements Runnable{
		private String id;
		public DestroyCollectionRunnable(String id){
			this.id = id;
		}
		@Override
		public void run() {
			try {
				if (Http.destroy_collection(Integer
						.parseInt(id))) {
					collections = Http.get_collections();
					mhandler.sendEmptyMessage(MESSAGE_DESTROY_COLLECTION_SUCCESS);
				} else {
					mhandler.sendEmptyMessage(MESSAGE_DESTROY_COLLECTION_FAIL);
				}
			} catch (NumberFormatException e) {
				e.printStackTrace();
			} catch (IntentException e) {
				e.printStackTrace();
				mhandler.sendEmptyMessage(MESSAGE_INTENT_CONNECTION_FAIL);
			}
		}
	}
}
