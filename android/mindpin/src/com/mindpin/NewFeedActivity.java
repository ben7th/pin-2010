package com.mindpin;

import java.util.ArrayList;
import com.mindpin.R;
import com.mindpin.Logic.CameraLogic;
import com.mindpin.Logic.Http;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
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
	protected static final int MESSAGE_SEND_SUCCESS = 0;
	LinearLayout feed_captures;
	private ArrayList<String> capture_paths = new ArrayList<String>();
	
	private EditText feed_title_et;
	private EditText feed_content_et;
	private String feed_title;
	private String feed_content;
	
	private ImageButton capture_bn;
	private Button send_bn;
	private ProgressDialog progress_dialog;
	private Handler mhandler = new Handler(){
		public void handleMessage(android.os.Message msg) {
			switch (msg.what) {
			case MESSAGE_SEND_SUCCESS:
				progress_dialog.dismiss();
				System.out.println("发送成功");
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
	}
	
	private void find_views() {
		feed_captures = (LinearLayout)findViewById(R.id.feed_captures);
		feed_title_et = (EditText) findViewById(R.id.feed_title_et);
		feed_content_et = (EditText) findViewById(R.id.feed_content_et);
	}
	
	private void process_extra() {
		boolean has_image_capture = getIntent().
				getBooleanExtra(CameraLogic.HAS_IMAGE_CAPTURE, false);
		if(has_image_capture){
			add_image_capture_to_feed_captures();
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
		capture_paths.add(path);
		BitmapFactory.Options options=new BitmapFactory.Options();
		options.inSampleSize = 8;
		Bitmap b = BitmapFactory.decodeFile(path, options);
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
		img.setTag(path); 
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
		Http.send_feed(feed_title, feed_content, capture_paths);
		mhandler.sendEmptyMessage(MESSAGE_SEND_SUCCESS);
	}
}
