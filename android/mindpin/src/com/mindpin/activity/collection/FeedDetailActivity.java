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
import android.view.GestureDetector;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.widget.Gallery;
import android.widget.ImageSwitcher;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.ViewFlipper;
import android.widget.ViewSwitcher.ViewFactory;

import com.mindpin.R;
import com.mindpin.Logic.FeedPhotoSwitch;
import com.mindpin.Logic.Http;
import com.mindpin.application.MindpinApplication;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.base.task.MindpinAsyncTask;
import com.mindpin.base.utils.BaseUtils;
import com.mindpin.cache.FeedImageCache;
import com.mindpin.database.Feed;

public class FeedDetailActivity extends MindpinBaseActivity {
	public static String EXTRA_NAME_FEED_ID = "feed_id";
	private ImageSwitcher feed_photos_image_switcher;
	private TextView feed_photos_footer;
	private int photos_current_index = 0;
	private ArrayList<String> photo_urls;
	private MotionEvent down_event;

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
		try {
			this.photo_urls = feed.photos_large;
			if(photo_urls.size()!=0){
				this.feed_photos_image_switcher = (ImageSwitcher)findViewById(R.id.feed_photos_image_switcher);
				this.feed_photos_footer = (TextView)findViewById(R.id.feed_photos_footer);
				feed_photos_image_switcher.setLongClickable(true);
				feed_photos_image_switcher.setFactory(new ViewFactory() {
					@Override
					public View makeView() {
						ImageView view = new ImageView(MindpinApplication.context);
						view.setImageResource(R.drawable.img_loading);
						return view;
					}
				});
				// 显示第一幅图片
				show_current_image();
				OnTouchListener touch_listener = new OnTouchListener() {
					@Override
					public boolean onTouch(View v, MotionEvent event) {
						return on_touch_event(event);
					}
				};
				// 滚动条和 image_switcher 都需要注册事件
				// 这样当 从图片内滑到图片外时才能正常工作
				feed_photos_image_switcher.setOnTouchListener(touch_listener);
				ScrollView feed_detail_scroll = (ScrollView)findViewById(R.id.feed_detail_scroll);
				feed_detail_scroll.setOnTouchListener(touch_listener);
			}
		} catch (Exception e) {
			System.out.println("显示主题图片出错了");
			e.printStackTrace();
		}		
	}
	
	public boolean on_touch_event(MotionEvent event) {
		System.out.println(event.getAction() );
		if(event.getAction() == MotionEvent.ACTION_DOWN){
			this.down_event = MotionEvent.obtain(event);
		}else if(event.getAction() == MotionEvent.ACTION_UP){
			float down_x = this.down_event.getX();
			float up_x = event.getX();
			if(Math.abs(down_x-up_x) > 50){
				if(down_x > up_x){
					on_left();
				}else{
					on_right();
				}
			}
		}
		return true;
	}
	
	private void show_current_image() {
		ImageView image_view = (ImageView) feed_photos_image_switcher.getNextView();
		image_view.setImageResource(R.drawable.img_loading);
		feed_photos_image_switcher.showNext();
		String footer_text = photos_current_index  + 1 + "/" + photo_urls.size();
		feed_photos_footer.setText(footer_text);
		
		String image_url = photo_urls.get(photos_current_index);
		FeedImageCache.load_cached_image(image_url, image_view);
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
	
	private void on_right() {
		if(photos_current_index > 0){
			System.out.println("right");
			photos_current_index--;
			show_current_image();
		}
	}

	private void on_left() {
		if(photos_current_index+1 < photo_urls.size()){
			System.out.println("left");
			photos_current_index++;
			show_current_image();
		}
	}

}
