package com.mindpin.activity.collection;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.mindpin.R;
import com.mindpin.Logic.Http;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.base.task.MindpinAsyncTask;
import com.mindpin.base.utils.BaseUtils;
import com.mindpin.database.Feed;
import com.mindpin.widget.DownloadFeedPhotoTask;

public class FeedDetailActivity extends MindpinBaseActivity {
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
	
	//显示feed详细信息
	private void show_feed(Feed feed) {
		// 渲染照片
		show_feed_photos(feed);
		
		//填写标题
		TextView title_tv = (TextView)findViewById(R.id.feed_title);
		String title = feed.title;
		if(BaseUtils.is_str_blank(title)){
			title_tv.setVisibility(View.GONE);
		}else{
			title_tv.setText(title);
		}

		//填写正文
		TextView detail_tv = (TextView)findViewById(R.id.feed_detail);
		String detail = feed.detail;
		if(BaseUtils.is_str_blank(detail)){
			detail_tv.setVisibility(View.GONE);
		}else{
			detail_tv.setText(detail);
		}
		
		//作者名字
		TextView creator_name_tv = (TextView)findViewById(R.id.creator_name);
		String name = feed.user_name;
		creator_name_tv.setText(name);
		
		//作者头像
		ImageView creator_logo_iv = (ImageView) findViewById(R.id.creator_logo);
		String url = feed.user_logo_url;
		creator_logo_iv.setImageBitmap(get_bitmap(url));
	}
	
	private void show_feed_photos(Feed feed) {
		ArrayList<String> photo_urls = feed.photos_large;
		if(photo_urls.size()!=0){
			LinearLayout feed_photos_ll = (LinearLayout)findViewById(R.id.feed_photos);
			for (String photo : photo_urls) {
				ImageView img = new ImageView(this);
				img.setAdjustViewBounds(true);
				BitmapDrawable draw = (BitmapDrawable)getResources().getDrawable(R.drawable.img_loading);
				img.setImageBitmap(draw.getBitmap());
				feed_photos_ll.addView(img);
				DownloadFeedPhotoTask task = new DownloadFeedPhotoTask(feed,photo,img);
				task.execute();
			}
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

}
