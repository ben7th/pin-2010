package com.mindpin;


import com.mindpin.Logic.AccountManager;
import com.mindpin.Logic.AccountManager.AuthenticateException;
import com.mindpin.Logic.CameraLogic;
import com.mindpin.Logic.Http;
import com.mindpin.Logic.Http.IntentException;
import com.mindpin.cache.AccountInfoCache;
import com.mindpin.utils.BaseUtils;
import com.mindpin.widget.MindpinAlertDialog;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends Activity {
	public static final int MESSAGE_SYN_COLLECTIONS_SUCCESS = 1;
	public static final int MESSAGE_INTENT_CONNECTION_FAIL = 2;
	public static final int MESSAGE_UPDATE_NOTICE = 3;
	public static final int MESSAGE_AUTH_FAIL = 4;
	
	private Intent to_new_feed;
	private Intent to_collection_list;
	private LinearLayout bn_new_feed;
	private LinearLayout bn_camera;
	private LinearLayout bn_feeds;
	private LinearLayout bn_collections;
	private TextView notice_tv;
	private ProgressBar notice_bar;
	private boolean has_pause = false;
	private Handler mhandler = new Handler(){
		public void handleMessage(android.os.Message msg) {
			switch (msg.what) {
			case MESSAGE_INTENT_CONNECTION_FAIL:
				notice_tv.setText("网络连接异常");
				notice_bar.setProgress(100);
				notice_bar.setVisibility(View.GONE);
				break;
			case MESSAGE_SYN_COLLECTIONS_SUCCESS:
				notice_tv.setText("同步收集册列表完成");
				notice_bar.setProgress(50);
				notice_bar.setVisibility(View.VISIBLE);
				break;
			case MESSAGE_UPDATE_NOTICE:
				long time = AccountManager.last_syn_time(getApplicationContext());
				String str = BaseUtils.date_string(time);
				notice_tv.setText("上次同步于 "+str);
				notice_bar.setProgress(100);
				notice_bar.setVisibility(View.GONE);
				UpdateUserInfoTask task = new UpdateUserInfoTask();
				task.execute();
				break;
			case MESSAGE_AUTH_FAIL:
				AccountManager.logout();
				Toast.makeText(getApplicationContext(), R.string.auth_fail_tip,
						Toast.LENGTH_SHORT).show();
				startActivity(new Intent(MainActivity.this,LoginActivity.class));
				MainActivity.this.finish();
				break;
			}
		};
	};
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);
		to_new_feed = new Intent(this,NewFeedActivity.class);
		to_collection_list = new Intent(this,CollectionListActivity.class);
		
		bn_new_feed = (LinearLayout)findViewById(R.id.main_bn_new_feed);
		bn_new_feed.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				startActivity(to_new_feed);
			}
		});
		
		bn_camera = (LinearLayout)findViewById(R.id.main_bn_camera);
		bn_camera.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				CameraLogic.call_sysotem_camera(MainActivity.this);
			}
		});
		
		bn_feeds = (LinearLayout)findViewById(R.id.main_bn_feeds);
		bn_feeds.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
//				Toast.makeText(getApplicationContext(),"浏览主题正在施工中...",
//						Toast.LENGTH_SHORT).show();
				

				MindpinAlertDialog dialog = new MindpinAlertDialog(MainActivity.this);
				dialog.set_title("我是标题");
				dialog.set_message("我是内容");
//				dialog.set_content(R.layout.main);
				dialog.set_button1("确定", new DialogInterface.OnClickListener(){
					public void onClick(DialogInterface dialog, int which) {
					}
				});
				dialog.set_button3("取消", new DialogInterface.OnClickListener(){
					public void onClick(DialogInterface dialog, int which) {
					}
				});
				dialog.show();
				
			}
		});
		
		bn_collections = (LinearLayout) findViewById(R.id.main_bn_collections);
		bn_collections.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				startActivity(to_collection_list);
			}
		});
		
		ImageView account_logo_img = (ImageView)findViewById(R.id.account_logo);
		TextView account_name_tv = (TextView)findViewById(R.id.account_name);
		account_name_tv.setText(AccountInfoCache.get_name());
		Bitmap b = BitmapFactory.decodeFile(AccountInfoCache.get_logo_path());
		account_logo_img.setImageBitmap(b);
		
		start_syn();
	}
	
	private void start_syn() {
		notice_tv = (TextView)findViewById(R.id.main_notice);		
		notice_bar = (ProgressBar)findViewById(R.id.main_notice_bar);
		
		notice_tv.setText("正在同步...");
		notice_bar.setProgress(20);
		notice_bar.setVisibility(View.VISIBLE);
		Thread thread = new Thread(new SynDataRunnable());
		thread.setDaemon(true);
		thread.start();
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.main,menu);
		return super.onCreateOptionsMenu(menu);
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case R.id.about:
			startActivity(new Intent(this, AboutActivity.class));
			break;
		case R.id.logout:
			logout_dialog();
			break;
		}

		return super.onOptionsItemSelected(item);
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(resultCode != Activity.RESULT_OK){
			return;
		}
		
		switch (requestCode) {
		case CameraLogic.REQUEST_CAPTURE:
			Intent intent = new Intent(MainActivity.this,NewFeedActivity.class);
			intent.putExtra(CameraLogic.HAS_IMAGE_CAPTURE,true);
			startActivity(intent);
			break;
		}
		super.onActivityResult(requestCode, resultCode, data);
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		 if(keyCode == KeyEvent.KEYCODE_BACK){
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setMessage("是否退出 Mindpin？");
			builder.setPositiveButton("是",new DialogInterface.OnClickListener(){
				public void onClick(DialogInterface dialog, int which) {
					MainActivity.this.finish();
				}
			});
			builder.setNegativeButton("否",new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
				}
			});
			builder.show();
			return true;
		 }
		return super.onKeyDown(keyCode, event);
	}
	
	@Override
	protected void onPause() {
		has_pause = true;
		super.onPause();
	}
	
	@Override
	protected void onResume() {
		if(has_pause){
			mhandler.sendEmptyMessage(MESSAGE_UPDATE_NOTICE);
		}
		super.onResume();
	}
	
	private void logout_dialog() {
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setMessage("退出登录会清除个人缓存以及个人的推迟发送的主题，确定退出么？");
		builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				AccountManager.logout();
				startActivity(new Intent(MainActivity.this, LoginActivity.class));
				MainActivity.this.finish();
			}
		});
		builder.setNegativeButton("取消",null);
		builder.show();
	}
	
	public class SynDataRunnable implements Runnable {
		public void run() {
			try {
				Http.syn_data();
				mhandler.sendEmptyMessage(MESSAGE_SYN_COLLECTIONS_SUCCESS);
				AccountManager.touch_last_syn_time(getApplicationContext());
			} catch (IntentException e) {
				mhandler.sendEmptyMessage(MESSAGE_INTENT_CONNECTION_FAIL);
			} catch (AuthenticateException e) {
				mhandler.sendEmptyMessage(MESSAGE_AUTH_FAIL);
			}
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			mhandler.sendEmptyMessage(MESSAGE_UPDATE_NOTICE);
		}
	};
	
	public class UpdateUserInfoTask extends AsyncTask<String, String, Bitmap>{

		protected Bitmap doInBackground(String... params) {
			return BitmapFactory.decodeFile(AccountInfoCache.get_logo_path());
		}
		
		protected void onPostExecute(Bitmap result) {
			super.onPostExecute(result);
			TextView account_name_tv = (TextView)findViewById(R.id.account_name);
			account_name_tv.setText(AccountInfoCache.get_name());
			ImageView account_logo_img = (ImageView)findViewById(R.id.account_logo);
			account_logo_img.setImageBitmap(result);
		}
	}
}
