package com.mindpin;

import java.util.Timer;
import java.util.TimerTask;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.os.Bundle;
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

import com.mindpin.Logic.AccountManager;
import com.mindpin.Logic.CameraLogic;
import com.mindpin.Logic.Http;
import com.mindpin.cache.AccountInfoCache;
import com.mindpin.runnable.MindpinAsyncTask;
import com.mindpin.utils.BaseUtils;
import com.mindpin.widget.MindpinAlertDialog;

public class MainActivity extends Activity {
	private TextView data_syn_textview;
	private ProgressBar data_syn_progress_bar;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);
		

		data_syn_textview = (TextView)findViewById(R.id.main_data_syn_text);
		data_syn_progress_bar = (ProgressBar)findViewById(R.id.main_data_syn_progress_bar);
		
		bind_all_buttons_events();
		update_account_info();
		data_syn();
	}
	
	private void bind_all_buttons_events(){
		bind_new_feed_button_event();
		bind_camera_button_event();
		bind_feeds_button_event();
		bind_collections_button_event();
	}
	
	//设置 new_feed 按钮点击事件
	private void bind_new_feed_button_event(){
		LinearLayout new_feed_button = (LinearLayout)findViewById(R.id.main_button_new_feed);
		new_feed_button.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Intent intent_to_new_feed = new Intent(MainActivity.this,NewFeedActivity.class);
				startActivity(intent_to_new_feed);
			}
		});
	}
	
	//设置 camera 按钮点击事件
	private void bind_camera_button_event(){
		LinearLayout camera_button = (LinearLayout)findViewById(R.id.main_button_camera);
		camera_button.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				CameraLogic.call_sysotem_camera(MainActivity.this);
			}
		});
	}
	
	//设置 feeds 按钮点击事件
	private void bind_feeds_button_event(){
		LinearLayout feeds_button = (LinearLayout)findViewById(R.id.main_button_feeds);
		feeds_button.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
//				Toast.makeText(getApplicationContext(),"浏览主题正在施工中...",
//						Toast.LENGTH_SHORT).show();
				

				MindpinAlertDialog dialog = new MindpinAlertDialog(MainActivity.this);
				dialog.set_title("我是标题");
				dialog.set_message("我是内容");
//				dialog.set_content(R.layout.main);
				dialog.set_button1("确定", new DialogInterface.OnClickListener(){
					public void onClick(DialogInterface dialog, int which) {
						//..
					}
				});
				dialog.set_button3("取消", new DialogInterface.OnClickListener(){
					public void onClick(DialogInterface dialog, int which) {
						//..
					}
				});
				dialog.show();
				
			}
		});
	}
	
	//设置collections按钮点击事件
	private void bind_collections_button_event(){
		
		
		LinearLayout collections_button = (LinearLayout) findViewById(R.id.main_button_collections);
		collections_button.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Intent intent_to_collection_list = new Intent(MainActivity.this, CollectionListActivity.class);
				startActivity(intent_to_collection_list);
			}
		});
	}
	
	
	// 在界面上刷新头像和用户名的任务
	public class UpdateAccountInfoTask extends AsyncTask<String, String, Bitmap>{
		protected Bitmap doInBackground(String... params) {
			return AccountInfoCache.get_avatar_bitmap();
		}
		
		protected void onPostExecute(Bitmap result) {
			TextView account_name_textview = (TextView)findViewById(R.id.account_name);
			ImageView account_avatar_imgview = (ImageView)findViewById(R.id.account_avatar);
			
			//account_name_textview.setText(AccountInfoCache.get_name());
			//account_avatar_imgview.setImageBitmap(result);
		}
	}
	
	private void update_account_info(){
		new UpdateAccountInfoTask().execute();
	}
	
	//同步操作
	private void data_syn() {
		new MindpinAsyncTask<String, Integer>(this){
			@Override
			public void on_start() {
				data_syn_textview.setText("正在同步数据…");
				data_syn_progress_bar.setProgress(0);
				data_syn_progress_bar.setVisibility(View.VISIBLE);
			}
			
			@Override
			public void do_in_background(String... params) throws Exception {
				Timer timer = new Timer();
				TimerTask timer_task = new TimerTask() {
					@Override
					public void run() {
						int current_value = data_syn_progress_bar.getProgress();
						if(current_value < 90){
							publish_progress(current_value+2);
						}
						
					}
				};
				timer.schedule(timer_task, 100, 100);
				Http.syn_data();
				timer.cancel();
				publish_progress(100);
				Thread.sleep(500);
			}
			
			public void on_progress_update(Integer... values) {
				int value = values[0];
				data_syn_progress_bar.setProgress(value);
				if(100 == value){
					data_syn_textview.setText("同步完毕");
				}
			};

			@Override
			public void on_success() {
				AccountManager.touch_last_syn_time(getApplicationContext());
				data_syn_progress_bar.setProgress(100);
				update_account_info();
			}
			
			public void on_unknown_exception() {
				data_syn_textview.setText("网络连接异常");
				data_syn_progress_bar.setProgress(0);
				data_syn_progress_bar.setVisibility(View.GONE);
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
			startActivity(new Intent(this, MindpinPreferenceActivity.class));
			break;
		case R.id.menu_logout:
			show_logout_dialog();
			break;
		}

		return super.onOptionsItemSelected(item);
	}
	
	private void show_logout_dialog() {
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		
		builder.setTitle(R.string.dialog_logout_title);
		builder.setMessage(R.string.dialog_logout_text);
		
		builder.setPositiveButton(R.string.dialog_ok, new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				AccountManager.logout();
				startActivity(new Intent(MainActivity.this, LoginActivity.class));
				MainActivity.this.finish();
			}
		});
		builder.setNegativeButton(R.string.dialog_cancel, null);
		builder.show();
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
	
	//这个方法是干啥的？
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
}
