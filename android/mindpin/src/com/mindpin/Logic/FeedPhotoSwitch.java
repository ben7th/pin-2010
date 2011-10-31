package com.mindpin.Logic;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;

import com.mindpin.R;
import com.mindpin.application.MindpinApplication;
import com.mindpin.cache.FeedImageCache;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.View.OnTouchListener;
import android.widget.ImageSwitcher;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.ViewSwitcher;
import android.widget.ViewSwitcher.ViewFactory;

public class FeedPhotoSwitch {
	private static final int FLING_MIN_DISTANCE = 30;
    private static final int FLING_MIN_VELOCITY = 10;

	private LinearLayout feed_photos_ll;
	private ImageSwitcher feed_photos_image_switcher;
	private TextView feed_photos_footer;
	
	private ArrayList<String> photo_urls;
	private int current_index = 0;

	public FeedPhotoSwitch(LinearLayout feed_photos_ll,ArrayList<String> photo_urls){
		this.feed_photos_ll = feed_photos_ll;
		this.photo_urls = photo_urls;
		this.feed_photos_image_switcher = (ImageSwitcher)feed_photos_ll.findViewById(R.id.feed_photos_image_switcher);
		this.feed_photos_footer = (TextView)feed_photos_ll.findViewById(R.id.feed_photos_footer);
		init();
	}

	private void init() {
		feed_photos_image_switcher.setLongClickable(true);
		feed_photos_image_switcher.setFactory(new ViewFactory() {
			@Override
			public View makeView() {
				ImageView view = new ImageView(MindpinApplication.context);
				view.setImageResource(R.drawable.img_loading);
				return view;
			}
		});
		// ÏÔÊ¾µÚÒ»·ùÍ¼Æ¬
		show_current_image();
		// ×¢²áÇÐ»»Í¼Æ¬ÊÂ¼þ
		feed_photos_image_switcher.setOnTouchListener(new ImageTouchListener());
	}
	
	private void show_current_image(){
		ImageView image_view = (ImageView) feed_photos_image_switcher.getNextView();
		image_view.setImageResource(R.drawable.img_loading);
		feed_photos_image_switcher.showNext();
		String footer_text = current_index + 1 + "/" + photo_urls.size();
		feed_photos_footer.setText(footer_text);
		
		String image_url = photo_urls.get(current_index);
		FeedImageCache.load_cached_image(image_url, image_view);
	}
	
	class ImageTouchListener implements OnTouchListener{
		private MotionEvent down_event;

		@Override
		public boolean onTouch(View v, MotionEvent event) {
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
			}else if(event.getAction() == MotionEvent.ACTION_CANCEL){
				float down_x = this.down_event.getX();
				float up_x = event.getX();
				if(Math.abs(down_x-up_x) > 20){
					if(down_x > up_x){
						on_left();
					}else{
						on_right();
					}
				}
			}
			return true;
		}

		private void on_right() {
			if(current_index > 0){
				System.out.println("right");
				current_index--;
				show_current_image();
			}
		}

		private void on_left() {
			if(current_index+1 < photo_urls.size()){
				System.out.println("left");
				current_index++;
				show_current_image();
			}
		}
		
	}
}
