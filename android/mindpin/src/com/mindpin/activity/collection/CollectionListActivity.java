package com.mindpin.activity.collection;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.Toast;

import com.mindpin.R;
import com.mindpin.Logic.Http;
import com.mindpin.cache.CollectionsCache;
import com.mindpin.runnable.MindpinHandler;
import com.mindpin.runnable.MindpinRunnable;

public class CollectionListActivity extends Activity {
	public static final int MESSAGE_READ_COLLECTION_LIST_SUCCESS = 0;
	protected static final int MESSAGE_CREATE_COLLECTION_SUCCESS = 1;
	protected static final int MESSAGE_CREATE_COLLECTION_FAIL = 2;
	public static final int MESSAGE_INTENT_CONNECTION_FAIL = 3;
	public static final int MESSAGE_AUTH_FAIL = 4;
	private ProgressDialog progress_dialog;
	private List<HashMap<String, Object>> collections;
	private ListView collection_list_lv;
	private Button new_collection;
	private boolean has_pause = false;

	private MindpinHandler mhandler = new MindpinHandler(this) {
		public boolean mindpin_handle_message(android.os.Message msg) {
			progress_dialog.dismiss();
			switch (msg.what) {
			case MESSAGE_CREATE_COLLECTION_SUCCESS:
				build_collection_list();
				Toast.makeText(getApplicationContext(), "操作成功",
						Toast.LENGTH_SHORT).show();
				return true;
			case MESSAGE_CREATE_COLLECTION_FAIL:
				Toast.makeText(getApplicationContext(), "创建失败",
						Toast.LENGTH_SHORT).show();
				return true;
			}
			return false;
		};
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.collection_list);
		collection_list_lv = (ListView) findViewById(R.id.collection_list);

		new_collection = (Button) findViewById(R.id.new_collection);
		new_collection.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				show_new_collection_dialog();
			}
		});
		
		build_collection_list();
	}
	
	@Override
	protected void onResume() {
		if (has_pause) {
			ArrayList<HashMap<String, Object>> list = CollectionsCache
					.get_collection_list();
			if (!list.equals(collections)) {
				collections = list;
				build_collection_list_data();
			}
		}
		super.onResume();
	}

	@Override
	protected void onPause() {
		has_pause = true;
		super.onPause();
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
	
	private void build_collection_list() {
		collections = CollectionsCache.get_collection_list();
		build_collection_list_data();
		collection_list_lv.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				HashMap<String, Object> hash = collections.get(arg2);
				int id = (Integer) hash.get("id");
				String title = (String) hash.get("title");
				Intent intent = new Intent(CollectionListActivity.this,
						CollectionFeedListActivity.class);
				intent.putExtra(CollectionFeedListActivity.EXTRA_COLLECTION_ID,
						id);
				intent.putExtra(
						CollectionFeedListActivity.EXTRA_COLLECTION_TITLE,
						title);
				startActivity(intent);
			}
		});
	}
	
	private void build_collection_list_data() {
		SimpleAdapter sa = new SimpleAdapter(CollectionListActivity.this,
				collections, R.layout.collection_item, new String[] { "id",
						"title" }, new int[] { R.id.collection_id,
						R.id.collection_title });
		collection_list_lv.setAdapter(sa);
	}

	public class CreateCollectionRunnable extends MindpinRunnable{
		private String title;

		public CreateCollectionRunnable(String title) {
			super(mhandler);
			this.title = title;
		}

		@Override
		public void mindpin_run() throws Exception {
			boolean success;
			success = Http.create_collection(title);
			if (success) {
				mhandler.sendEmptyMessage(MESSAGE_CREATE_COLLECTION_SUCCESS);
			} else {
				mhandler.sendEmptyMessage(MESSAGE_CREATE_COLLECTION_FAIL);
			}
		}
	}
}
