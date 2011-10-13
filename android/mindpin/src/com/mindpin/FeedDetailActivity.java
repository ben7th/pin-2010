package com.mindpin;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import com.mindpin.Logic.AccountManager.AuthenticateException;
import com.mindpin.Logic.Http;
import com.mindpin.Logic.Http.IntentException;
import com.mindpin.utils.BaseUtils;
import com.mindpin.widget.DownloadImageTask;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

public class FeedDetailActivity extends Activity {
	public static final int MESSAGE_READ_FEED_SUCCESS = 0;
	public static final int MESSAGE_INTENT_CONNECTION_FAIL = 1;
	public static final int MESSAGE_AUTH_FAIL = 2;
	public static String EXTRA_NAME_FEED_ID = "feed_id";
	
	private String feed_id;
	private ProgressDialog progress_dialog;
	private HashMap<String,Object> feed;
	private Handler mhandler = new Handler(){
		public void handleMessage(Message msg) {
			super.handleMessage(msg);
			switch (msg.what) {
			case MESSAGE_INTENT_CONNECTION_FAIL:
				Toast.makeText(getApplicationContext(),R.string.app_intent_connection_fail,
						Toast.LENGTH_SHORT).show();
				break;
			case MESSAGE_AUTH_FAIL:
				Toast.makeText(getApplicationContext(), R.string.app_auth_fail,
						Toast.LENGTH_SHORT).show();
				startActivity(new Intent(FeedDetailActivity.this,
						LoginActivity.class));
				FeedDetailActivity.this.finish();
				break;
			case MESSAGE_READ_FEED_SUCCESS:
				show_feed();
				break;
			}
			progress_dialog.dismiss();
		}

	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.feed_detail);
		Bundle ex = getIntent().getExtras();
		feed_id = ex.getString(EXTRA_NAME_FEED_ID);
		progress_dialog = ProgressDialog.show(this, "", "正在读取数据...");
		Thread thread = new Thread(new ReadFeedRunnable());
		thread.setDaemon(true);
		thread.start();

	}
	
	//显示feed详细信息
	private void show_feed() {
		LinearLayout feed_photos_ll = (LinearLayout)findViewById(R.id.feed_photos);
		
		//加载所有图片，目前是同步，将来应改成异步
		ArrayList photo_urls = (ArrayList)feed.get("photos");
		for (Object photo_url : photo_urls) {
			ImageView img = new ImageView(this);
			img.setAdjustViewBounds(true); //设置这个使得图片缩放后内容合适
			Bitmap b = ((BitmapDrawable) getResources().getDrawable(
					R.drawable.img_loading)).getBitmap();
			img.setImageBitmap(b);
			feed_photos_ll.addView(img);
			DownloadImageTask task = new DownloadImageTask(img);
			task.execute((String)photo_url);
		}
		
		//填写标题
		_show_feed_set_text(R.id.feed_title,"title");

		//填写正文
		_show_feed_set_text(R.id.feed_detail,"detail");
		
		//作者名字
		TextView creator_name_tv = (TextView)findViewById(R.id.creator_name);
		String name = (String)feed.get("creator_name");
		creator_name_tv.setText(name);
		
		//作者头像
		ImageView creator_logo_iv = (ImageView) findViewById(R.id.creator_logo);
		String url = (String)feed.get("creator_logo_url");
		creator_logo_iv.setImageBitmap(get_bitmap(url));
	}
	
	private void _show_feed_set_text(int view_id,String text_name){
		TextView tv = (TextView)findViewById(view_id);
		String str = (String)feed.get(text_name);
		
		if(BaseUtils.isStrBlank(str)){
			tv.setVisibility(View.GONE);
		}else{
			tv.setText(str);
		}	
	}
	
	
	private Bitmap get_bitmap(String image_url) {
		Bitmap mBitmap = null;
		try {
			URL url = new URL(image_url);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			InputStream is = conn.getInputStream();
			mBitmap = BitmapFactory.decodeStream(is);
		} catch (MalformedURLException e) {
			e.printStackTrace();
			return mBitmap;
		} catch (IOException e) {
			e.printStackTrace();
			return mBitmap;
		}
		return mBitmap;
	}

	public class ReadFeedRunnable implements Runnable {
		public void run() {
			try {
				feed = Http.read_feed(feed_id);
				mhandler.sendEmptyMessage(MESSAGE_READ_FEED_SUCCESS);
			} catch (IntentException e) {
				mhandler.sendEmptyMessage(MESSAGE_INTENT_CONNECTION_FAIL);
			} catch (AuthenticateException e) {
				mhandler.sendEmptyMessage(MESSAGE_AUTH_FAIL);
			}
		}
	}
	
}
