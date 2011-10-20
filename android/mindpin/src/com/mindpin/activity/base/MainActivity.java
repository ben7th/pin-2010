package com.mindpin.activity.base;

import java.util.Timer;
import java.util.TimerTask;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;
import com.mindpin.R;
import com.mindpin.Logic.AccountManager;
import com.mindpin.Logic.CameraLogic;
import com.mindpin.Logic.Http;
import com.mindpin.activity.collection.CollectionListActivity;
import com.mindpin.activity.feed.FeedListActivity;
import com.mindpin.activity.sendfeed.NewFeedActivity;
import com.mindpin.base.task.MindpinAsyncTask;
import com.mindpin.base.utils.BaseUtils;

public class MainActivity extends Activity {
	private TextView data_syn_textview;
	private ProgressBar data_syn_progress_bar;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.base_main);
		
		data_syn_textview = (TextView)findViewById(R.id.main_data_syn_text);
		data_syn_progress_bar = (ProgressBar)findViewById(R.id.main_data_syn_progress_bar);
		
		update_account_info();
		data_syn();
	}
	
	//设置 new_feed 按钮点击事件
	public void main_button_new_feed_click(View view){
		Intent intent = new Intent(MainActivity.this,NewFeedActivity.class);
		startActivity(intent);
	}
	
	//设置 camera 按钮点击事件
	public void main_button_camera_click(View view){
		CameraLogic.call_system_camera(MainActivity.this);
	}
	
	//设置 feeds 按钮点击事件
	public void main_button_feeds_click(View view){
		Intent intent = new Intent(MainActivity.this,FeedListActivity.class);
		startActivity(intent);
	}
	
	//设置collections按钮点击事件
	public void main_button_collections_click(View view){
		Intent intent = new Intent(MainActivity.this, CollectionListActivity.class);
		startActivity(intent);
	}
	
	// 在界面上刷新头像和用户名
	private void update_account_info(){
		new MindpinAsyncTask<String, String, Bitmap>(this){
			@Override
			public Bitmap do_in_background(String... params) throws Exception {
				return AccountManager.get_current_user_avatar_bitmap();
			}

			@Override
			public void on_success(Bitmap result) {
				TextView account_name_textview = (TextView)findViewById(R.id.account_name);
				ImageView account_avatar_imgview = (ImageView)findViewById(R.id.account_avatar);
				
				account_name_textview.setText(AccountManager.get_current_user_name());
				account_avatar_imgview.setImageBitmap(result);
			}
		}.execute();
	}
	
	//同步操作
	private void data_syn() {
		new MindpinAsyncTask<String, Integer, Void>(this){
			@Override
			public void on_start() {
				data_syn_textview.setText("正在同步数据…");
				data_syn_progress_bar.setProgress(0);
				data_syn_progress_bar.setVisibility(View.VISIBLE);
			}
			
			@Override
			public Void do_in_background(String... params) throws Exception {
				Timer timer = new Timer();
				TimerTask timer_task = new TimerTask() {
					@Override
					public void run() {
						int current_value = data_syn_progress_bar.getProgress();
						if(current_value < 90){
							publish_progress(current_value+1);
						}
					}
				};
				timer.schedule(timer_task, 50, 50);
				Http.mobile_data_syn();
				timer.cancel();
				publish_progress(100);
				Thread.sleep(500);
				return null;
			}
			
			public void on_progress_update(Integer... values) {
				int value = values[0];
				data_syn_progress_bar.setProgress(value);
				if(100 == value){
					data_syn_textview.setText("同步完毕");
				}
			};

			@Override
			public void on_success(Void v) {
				AccountManager.touch_last_syn_time(getApplicationContext());
				data_syn_progress_bar.setProgress(100);
				update_account_info();
			}
			
			public boolean on_unknown_exception() {
				BaseUtils.toast(R.string.app_data_syn_fail);
				data_syn_progress_bar.setProgress(0);
				data_syn_progress_bar.setVisibility(View.GONE);
				return false;
			};
			
			public void on_final() {
				long time = AccountManager.last_syn_time(getApplicationContext());
				String str = BaseUtils.date_string(time);
				data_syn_textview.setText("数据同步于 "+str);
				data_syn_progress_bar.setVisibility(View.GONE);
			};
			
		}.execute();
	}
	

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.main, menu);
		return super.onCreateOptionsMenu(menu);
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case R.id.menu_about:
			startActivity(new Intent(this, AboutActivity.class));
			break;
		case R.id.menu_setting:
			startActivity(new Intent(this, MindpinSettingActivity.class));
			break;
		case R.id.menu_account_management:
			startActivity(new Intent(this, AccountManagerActivity.class));
			break;
		}

		return super.onOptionsItemSelected(item);
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		 if(keyCode == KeyEvent.KEYCODE_BACK){
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			
			builder.setTitle(R.string.dialog_close_app_title);
			builder.setMessage(R.string.dialog_close_app_text);
			
			builder.setPositiveButton(R.string.dialog_ok, new DialogInterface.OnClickListener(){
				public void onClick(DialogInterface dialog, int which) {
					MainActivity.this.finish();
				}
			});
			builder.setNegativeButton(R.string.dialog_cancel, null);
			builder.show();
			
			return true;
		 }
		return super.onKeyDown(keyCode, event);
	}
	
	//处理其他activity界面的回调
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(resultCode != Activity.RESULT_OK){
			return;
		}
		
		switch (requestCode) {
		case CameraLogic.REQUEST_CODE_CAPTURE:
			Intent intent = new Intent(MainActivity.this, NewFeedActivity.class);
			intent.putExtra(CameraLogic.HAS_IMAGE_CAPTURE, true);
			startActivity(intent);
			break;
		}
		
		super.onActivityResult(requestCode, resultCode, data);
	}
}
