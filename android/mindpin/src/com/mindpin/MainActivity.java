package com.mindpin;


import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;

import com.mindpin.Logic.AccountManager;
import com.mindpin.Logic.CameraLogic;
import com.mindpin.Logic.FeedHoldManager;
import com.mindpin.Logic.Http;
import com.mindpin.Logic.Http.IntentException;
import com.mindpin.application.MindpinApplication;
import com.mindpin.cache.AccountInfoCache;
import com.mindpin.cache.CollectionsCache;
import com.mindpin.database.FeedHold;
import com.mindpin.thread.SendFeedHoldThread;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Handler;
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
	public static final int MESSAGE_SYN_COLLECTIONS_SUCCESS = 0;
	public static final int MESSAGE_SEND_FEED_HOLDS_SUCCESS = 1;
	public static final int MESSAGE_INTENT_CONNECTION_FAIL = 2;
	public static final int MESSAGE_UPDATE_NOTICE = 3;
	
	private Timer send_feed_hold_timer;
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
			case MESSAGE_SEND_FEED_HOLDS_SUCCESS:
				notice_tv.setText("同步离线主题完成");
				notice_bar.setProgress(80);
				notice_bar.setVisibility(View.VISIBLE);
				break;
			case MESSAGE_SYN_COLLECTIONS_SUCCESS:
				notice_tv.setText("同步收集册列表完成");
				notice_bar.setProgress(50);
				notice_bar.setVisibility(View.VISIBLE);
			case MESSAGE_UPDATE_NOTICE:
				int count = FeedHold.get_count(getApplicationContext());
				long time = AccountManager.last_syn_time(getApplicationContext());
				SimpleDateFormat sdf = new SimpleDateFormat();
				sdf.applyPattern("yyyy-MM-dd HH:mm:ss");
				String str = sdf.format(new Date(time));
				notice_tv.setText(count + "离线主题，"+"上次同步于 "+str);
				notice_bar.setProgress(100);
				notice_bar.setVisibility(View.GONE);
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
				Toast.makeText(getApplicationContext(),"浏览主题正在施工中...",
						Toast.LENGTH_SHORT).show();
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
		notice_bar = (ProgressBar) findViewById(R.id.main_notice_bar);
		notice_tv.setText("正在同步...");
		notice_bar.setProgress(20);
		notice_bar.setVisibility(View.VISIBLE);
		Thread thread = new Thread(new SynDataRunnable());
		thread.setDaemon(true);
		thread.start();
		
		MindpinApplication app = (MindpinApplication)getApplication();
		SendFeedHoldThread sf_thread = new SendFeedHoldThread(app);
		sf_thread.setDaemon(true);
		sf_thread.start();
		
		send_feed_hold_timer = new Timer();
		TimerTask task = new TimerTask() {
			public void run() {
				MindpinApplication app = (MindpinApplication)getApplication();
				app.send_feed_hold_handler.sendEmptyMessage(SendFeedHoldThread.MESSAGE_SEND_FEED_HOLD);
			}
		};
		send_feed_hold_timer.schedule(task, 30000, 30000);
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
	
	@Override
	protected void onDestroy() {
	    if (send_feed_hold_timer != null) {
	    	send_feed_hold_timer.cancel();
	    }
		super.onDestroy();
	}
	
	private void logout_dialog() {
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setMessage("退出登录会清除个人缓存以及个人的推迟发送的主题，确定退出么？");
		builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				AccountManager.remove_user_info(MainActivity.this);
				AccountInfoCache.destroy();
				CollectionsCache.destroy();
				FeedHold.destroy_all(getApplicationContext());
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
				Http.get_collections();
				mhandler.sendEmptyMessage(MESSAGE_SYN_COLLECTIONS_SUCCESS);
				if(FeedHold.get_count(getApplicationContext()) != 0){
					FeedHoldManager.send_feed_holds(getApplicationContext());
				}
				mhandler.sendEmptyMessage(MESSAGE_SEND_FEED_HOLDS_SUCCESS);
			} catch (IntentException e) {
				mhandler.sendEmptyMessage(MESSAGE_INTENT_CONNECTION_FAIL);
			}
			AccountManager.touch_last_syn_time(getApplicationContext());
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			mhandler.sendEmptyMessage(MESSAGE_UPDATE_NOTICE);
		}
	};
}
