package com.mindpin;

import java.io.IOException;
import java.util.ArrayList;
import com.mindpin.R;
import com.mindpin.Logic.AccountManager;
import com.mindpin.Logic.CameraLogic;
import com.mindpin.Logic.Http;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;
import android.widget.LinearLayout.LayoutParams;

public class NewFeedActivity extends Activity implements Runnable {
	public static final int REQUEST_SHOW_IMAGE_CAPTURE = 1;
	public static final int REQUEST_SHOW_IMAGE_ALBUM = 2;
	
	protected static final int MESSAGE_SEND_SUCCESS = 0;
	protected static final int MESSAGE_SEND_FAIL = 1;
	protected static final int MESSAGE_LOGGED = 2;
	protected static final int MESSAGE_UNLOGGED = 3;
	protected static final int MESSAGE_INTENT_FAIL = 4;
	LinearLayout feed_captures;
	private ArrayList<String> capture_paths = new ArrayList<String>();
	
	private EditText feed_title_et;
	private EditText feed_content_et;
	private String feed_title;
	private String feed_content;
	
	private ImageButton capture_bn;
	private Button send_bn;
	private Button album_bn;
	private ProgressDialog progress_dialog;
	private Handler mhandler = new Handler(){
		public void handleMessage(android.os.Message msg) {
			progress_dialog.dismiss();
			switch (msg.what) {
			case MESSAGE_SEND_SUCCESS:
				Toast.makeText(getApplicationContext(),"发送成功",
						Toast.LENGTH_SHORT).show();
				break;
			case MESSAGE_SEND_FAIL:
				Toast.makeText(getApplicationContext(),"发送失败",
						Toast.LENGTH_SHORT).show();
				break;
			case MESSAGE_LOGGED:
				break;
			case MESSAGE_UNLOGGED:
				alert("登录失败，请重新登录");
				break;
			case MESSAGE_INTENT_FAIL:
				alert("网络不可用");
				break;
			}
		};
	};
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.new_feed);
		find_views();
		set_listener();
		process_extra();
		process_share();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(resultCode != Activity.RESULT_OK){
			return;
		}
		switch (requestCode) {
		case CameraLogic.REQUEST_CAPTURE:
			add_image_capture_to_feed_captures();
			break;
		case REQUEST_SHOW_IMAGE_CAPTURE:
			process_request_show_image_capture_by_result_code(resultCode,data);
			break;
		case REQUEST_SHOW_IMAGE_ALBUM:
			Uri uri = data.getData();
			String path = get_absolute_imagePath(uri);
			add_image_to_feed_captures(path);
		}
		super.onActivityResult(requestCode, resultCode, data);
	}
	
	private void set_listener() {
		capture_bn = (ImageButton)findViewById(R.id.capture_bn);
		capture_bn.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				CameraLogic.call_sysotem_camera(NewFeedActivity.this);
			}
		});
		send_bn = (Button) findViewById(R.id.send_bn);
		send_bn.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				feed_title = feed_title_et.getText().toString();
				feed_content = feed_content_et.getText().toString();
				if(feed_title == null || "".equals(feed_title)){
					Toast.makeText(getApplicationContext(), R.string.feed_title_valid_blank,
							Toast.LENGTH_SHORT).show();
					return;
				}
				
				progress_dialog = ProgressDialog.show(NewFeedActivity.this,
						"","正在发送...");
				Thread thread = new Thread(NewFeedActivity.this);
				thread.setDaemon(true);
				thread.start();
			}
		});
		
		album_bn = (Button) findViewById(R.id.album_bn);
		album_bn.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Uri uri = MediaStore.Images.Media.INTERNAL_CONTENT_URI;
				Intent intent = new Intent("android.intent.action.PICK",
						uri);
				startActivityForResult(intent, REQUEST_SHOW_IMAGE_ALBUM);
			}
		});
	}
	
	private void find_views() {
		feed_captures = (LinearLayout)findViewById(R.id.feed_captures);
		feed_title_et = (EditText) findViewById(R.id.feed_title_et);
		feed_content_et = (EditText) findViewById(R.id.feed_content_et);
	}
	
	private void process_extra() {
		Intent it = getIntent();
		boolean has_image_capture = it.
				getBooleanExtra(CameraLogic.HAS_IMAGE_CAPTURE, false);
		if(has_image_capture){
			add_image_capture_to_feed_captures();
		}
	}
	
	private void process_share(){
		Intent it = getIntent();
		if (Intent.ACTION_SEND.equals(it.getAction())) {
			Bundle extras = it.getExtras();
			if (extras.containsKey("android.intent.extra.STREAM")) {
				Uri uri = (Uri) extras.get("android.intent.extra.STREAM");
				String path = get_absolute_imagePath(uri);
				add_image_to_feed_captures(path);
			}
			progress_dialog = ProgressDialog.show(NewFeedActivity.this, "",
					"正在登录...");
			LoginRunnable lr = new LoginRunnable();
			Thread thread = new Thread(lr);
			thread.setDaemon(true);
			thread.start();
		}
	}
	
	private void process_request_show_image_capture_by_result_code(
			int resultCode,Intent intent) {
		String button_name = intent.getStringExtra(showImageCaptureActivity.EXTRA_NAME_CLICK_BUTTON_NAME);
		if(button_name.equals(showImageCaptureActivity.EXTRA_VALUE_BACK)){
			return;
		}else if(button_name.equals(showImageCaptureActivity.EXTRA_VALUE_DELETE)){
			String path = intent
					.getStringExtra(showImageCaptureActivity.EXTRA_NAME_IMAGE_CAPTURE_PATH);
			int index = capture_paths.indexOf(path);
			ImageView image = (ImageView) feed_captures.getChildAt(index);
			feed_captures.removeView(image);
			capture_paths.remove(path);
		}
	}
	
	private void add_image_capture_to_feed_captures(){
		String path = CameraLogic.image_capture_temp_path.getPath();
		add_image_to_feed_captures(path);
	}
	
	private void add_image_to_feed_captures(String file_path){
		capture_paths.add(file_path);
		BitmapFactory.Options options=new BitmapFactory.Options();
		options.inSampleSize = 8;
		Bitmap b = BitmapFactory.decodeFile(file_path, options);
		ImageView img = new ImageView(this);
		img.setAdjustViewBounds(true);
		img.setMaxHeight(120);
		img.setMaxWidth(120);
		LayoutParams lp = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		lp.leftMargin = 1;
		lp.rightMargin = 1;
		img.setLayoutParams(lp);
		img.setImageBitmap(b);
		img.setClickable(true);
		img.setTag(file_path); 
		img.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				String image_path = (String)v.getTag();
				Intent intent = new Intent(NewFeedActivity.this,showImageCaptureActivity.class);
				intent.putExtra(showImageCaptureActivity.EXTRA_NAME_IMAGE_CAPTURE_PATH, image_path);
				startActivityForResult(intent,REQUEST_SHOW_IMAGE_CAPTURE);
			}
		});
		feed_captures.addView(img);
	}

	public void run() {
		boolean bol = Http.send_feed(feed_title, feed_content, capture_paths);
		if(bol){
			mhandler.sendEmptyMessage(MESSAGE_SEND_SUCCESS);
		}else{
			mhandler.sendEmptyMessage(MESSAGE_SEND_FAIL);
		}
	}
	
	private String get_absolute_imagePath(Uri uri) 
	   {
	       String [] proj={MediaStore.Images.Media.DATA};
	       Cursor cursor = managedQuery( uri,proj,        
	                       null,null,null); 
	       int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
	       cursor.moveToFirst();
	       return cursor.getString(column_index);
	   }
	
	private void alert(String content){
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setMessage(content);
		builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				NewFeedActivity.this.finish();
			}
		});
		builder.show();
	}
	
	class LoginRunnable implements Runnable{
		public void run() {
			String email = AccountManager.get_email(NewFeedActivity.this);
			String password = AccountManager.get_password(NewFeedActivity.this);
			try {
				if (!"".equals(email) && !"".equals(password)
						&& AccountManager.user_authenticate(email, password)) {
					// 显示内容
					Message msg = mhandler.obtainMessage();
					msg.what = MESSAGE_LOGGED;
					mhandler.sendMessage(msg);
				} else {
					// 显示登录框
					Message msg = mhandler.obtainMessage();
					msg.what = MESSAGE_UNLOGGED;
					mhandler.sendMessage(msg);
				}
			} catch (IOException e) {
				Message msg = mhandler.obtainMessage();
				msg.what = MESSAGE_INTENT_FAIL;
				mhandler.sendMessage(msg);
				e.printStackTrace();
			}
		}
	}
}
