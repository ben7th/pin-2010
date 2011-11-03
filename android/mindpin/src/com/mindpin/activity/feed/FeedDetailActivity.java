package com.mindpin.activity.feed;

import java.util.ArrayList;

import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import com.mindpin.R;
import com.mindpin.Logic.Http;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.base.task.MindpinAsyncTask;
import com.mindpin.base.utils.BaseUtils;
import com.mindpin.database.Feed;
import com.mindpin.widget.MindpinImageSwitcher;

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
		// 用户基本信息
		FeedHelper.set_part_feed_user_info(this, feed);
		
		// 渲染照片
		show_feed_photos(feed);
		
		//填写标题，正文
		FeedHelper.set_title((TextView)findViewById(R.id.feed_title), feed);
		FeedHelper.set_detail((TextView)findViewById(R.id.feed_detail), feed);
	}
	
	private void show_feed_photos(Feed feed) {
		try {
			ArrayList<String> photo_urls = feed.photos_middle;
			RelativeLayout photos_layout = (RelativeLayout) findViewById(R.id.feed_detail_photos);
			TextView footer = (TextView) findViewById(R.id.feed_detail_photos_footer);
			
			if (photo_urls.size() > 0) {
				photos_layout.setVisibility(View.VISIBLE);
				
				final MindpinImageSwitcher switcher = (MindpinImageSwitcher) findViewById(R.id.feed_detail_photos_image_switcher);
				switcher.load_urls(photo_urls, feed.photos_ratio, footer);

				// 注册左右手势滑动事件
				OnTouchListener touch_listener = new OnTouchListener() {
					@Override
					public boolean onTouch(View v, MotionEvent event) {
						switcher.onTouchEvent(event);
						return false;
					}
				};
				ScrollView feed_detail_scroll = (ScrollView) findViewById(R.id.feed_detail_scroll);
				feed_detail_scroll.setOnTouchListener(touch_listener);
			}else{
				photos_layout.setVisibility(View.GONE);
			}
		} catch (Exception e) {
			e.printStackTrace();
			BaseUtils.toast("图片加载错误");
		}		
	}
	
}
