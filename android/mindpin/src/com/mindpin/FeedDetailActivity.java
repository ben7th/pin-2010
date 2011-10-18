package com.mindpin;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.mindpin.Logic.Feed;
import com.mindpin.Logic.Http;
import com.mindpin.runnable.MindpinAsyncTask;
import com.mindpin.utils.BaseUtils;
import com.mindpin.widget.DownloadImageTask;

public class FeedDetailActivity extends Activity {
	public static String EXTRA_NAME_FEED_ID = "feed_id";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.feed_detail);
		
		load_feed_detail();
	}
	
	private void load_feed_detail(){
		Bundle ex = getIntent().getExtras();
		String feed_id = ex.getString(EXTRA_NAME_FEED_ID);
		
		new MindpinAsyncTask<String, Void, Feed>(this, R.string.app_now_loading) {			
			@Override
			public Feed do_in_background(String... params) throws Exception {
				String feed_id = params[0];
				return Http.read_feed(feed_id);
			}

			@Override
			public void on_success(Feed feed) {
				show_feed(feed);
			}
		}.execute(feed_id);
	}
	
	//��ʾfeed��ϸ��Ϣ
	private void show_feed(Feed feed) {
		LinearLayout feed_photos_ll = (LinearLayout)findViewById(R.id.feed_photos);
		
		ArrayList<String> photo_urls = feed.getPhotos();
		for (String photo_url : photo_urls) {
			ImageView img = new ImageView(this);
			img.setAdjustViewBounds(true); //�������ʹ��ͼƬ���ź����ݺ���
			Bitmap b = ((BitmapDrawable) getResources().getDrawable(
					R.drawable.img_loading)).getBitmap();
			img.setImageBitmap(b);
			feed_photos_ll.addView(img);
			DownloadImageTask task = new DownloadImageTask(img);
			task.execute(photo_url);
		}
		
		//��д����
		TextView title_tv = (TextView)findViewById(R.id.feed_title);
		String title = feed.getTitle();
		if(BaseUtils.isStrBlank(title)){
			title_tv.setVisibility(View.GONE);
		}else{
			title_tv.setText(title);
		}

		//��д����
		TextView detail_tv = (TextView)findViewById(R.id.feed_detail);
		String detail = feed.getDetail();
		if(BaseUtils.isStrBlank(detail)){
			detail_tv.setVisibility(View.GONE);
		}else{
			detail_tv.setText(detail);
		}
		
		//��������
		TextView creator_name_tv = (TextView)findViewById(R.id.creator_name);
		String name = feed.getCreator_name();
		creator_name_tv.setText(name);
		
		//����ͷ��
		ImageView creator_logo_iv = (ImageView) findViewById(R.id.creator_logo);
		String url = feed.getCreator_logo_url();
		creator_logo_iv.setImageBitmap(get_bitmap(url));
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

}
