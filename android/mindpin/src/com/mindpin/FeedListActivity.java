package com.mindpin;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;

import com.mindpin.Logic.Http;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.Toast;

public class FeedListActivity extends Activity {
	private final int GROUP_DEFAULT = 0;
	private final int MENU_ABOUT = 1;
	private final int MENU_LOGOUT = 2;
	
	private final int MESSAGE_FEED_LIST_LOAD_OK=0;
	
	private final int REQUEST_CAPTURE = 0;
	
	
	private List<HashMap<String, Object>> feed_list;
	private ProgressDialog progressDialog;
	private Handler mhandler = new Handler(){
		public void handleMessage(android.os.Message msg) {
			switch (msg.what) {
			case MESSAGE_FEED_LIST_LOAD_OK:
				build_feed_list_view();
				progressDialog.dismiss();
				break;
			default:
				break;
			}
		};
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.feed_list);
		
		Button b = (Button)findViewById(R.id.new_photo_feed);
		b.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
				File out = new File(Environment.getExternalStorageDirectory(), "lifei_feed.jpg");
				Uri uri = Uri.fromFile(out);
				intent.putExtra(MediaStore.EXTRA_OUTPUT, uri);
				startActivityForResult(intent, REQUEST_CAPTURE);
			}
		});
		
		progressDialog = ProgressDialog.show(this,
				"","正在读取信息...");
		Thread thread = new Thread(new Runnable() {
			public void run() {
				load_feed_list();
			}
		});
		thread.setDaemon(true);
		thread.start();
	}

	public boolean onCreateOptionsMenu(Menu menu) {
		menu.add(GROUP_DEFAULT, MENU_ABOUT, 0, R.string.about);
		menu.add(GROUP_DEFAULT, MENU_LOGOUT, 0, R.string.logout);
		return super.onCreateOptionsMenu(menu);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case MENU_ABOUT:
			startActivity(new Intent(this, AboutActivity.class));
			break;
		case MENU_LOGOUT:
			remove_user_info();
			startActivity(new Intent(this, LoginActivity.class));
			this.finish();
			break;
		}

		return super.onOptionsItemSelected(item);
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		if(resultCode != Activity.RESULT_OK){
			return;
		}
		switch (requestCode) {
		case REQUEST_CAPTURE:
			break;
		default:
			break;
		}

	}
	
	private void load_feed_list() {
		try {
			feed_list = Http.get_feed_timeline();
		} catch (IOException e) {
			Toast.makeText(getApplicationContext(), "网络连接异常",
					Toast.LENGTH_SHORT).show();
			e.printStackTrace();
		}
		Message msg = mhandler.obtainMessage();
		msg.what = MESSAGE_FEED_LIST_LOAD_OK;
		mhandler.sendMessage(msg);
	}

	private void build_feed_list_view() {
		ListView fl = (ListView) findViewById(R.id.feed_list);
		SimpleAdapter adapter = new SimpleAdapter(this, feed_list,
				R.layout.feed_item, new String[] { "id", "content" },
				new int[] { R.id.feed_id, R.id.feed_content });
		fl.setAdapter(adapter);
		fl.setOnItemClickListener(new OnItemClickListener() {
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				HashMap<String, Object> map = feed_list.get(position);
				int feed_id = (Integer) map.get("id");
				Intent intent = new Intent(FeedListActivity.this,
						FeedDetailActivity.class);
				intent.putExtra("feed_id", feed_id);
				startActivity(intent);
			}
		});
	}
	

	private void remove_user_info() {
		SharedPreferences pre = getSharedPreferences(
				LoadingActivity.PREFERENCES_NAME, MODE_PRIVATE);
		Editor pre_edit = pre.edit();
		pre_edit.remove("email");
		pre_edit.remove("password");
		pre_edit.commit();
	}
}
