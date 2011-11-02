package com.mindpin.widget;

import java.util.ArrayList;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.ViewAnimator;

import com.mindpin.R;
import com.mindpin.cache.ImageCache;

public class MindpinImageSwitcher extends ViewAnimator {
	private ArrayList<String> image_urls;
	private MotionEvent down_event;
	private TextView footer;

	public MindpinImageSwitcher(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public MindpinImageSwitcher(Context context) {
		super(context);
	}

	public void load_urls(ArrayList<String> image_urls, TextView footer) {
		this.image_urls = image_urls;
		this.footer = footer;
		for (int i = 0; i < image_urls.size(); i++) {
			ImageView image_view = new ImageView(getContext());
			addView(image_view, i);
		}
		show_first();
	}

	private void show_first(){
		load_bitmap(0);
		load_bitmap(1);
		setDisplayedChild(0);
		footer.setText("1/"+image_urls.size());
	}
	

	@Override
	public void showNext() {
		int index = getDisplayedChild();
		if (index >= getChildCount() - 1) {
			// 到最后了
			return;
		}
		
		setInAnimation(getContext(), R.anim.slide_in_right);
		setOutAnimation(getContext(), R.anim.slide_out_left);
		if(index<image_urls.size()-1){
			load_bitmap(index+1);
		}
		load_bitmap(index+1);
		setDisplayedChild(index+1);
		if(index-1>=0){
			remove_bitmap(index-1);
		}
		footer.setText(index+2+"/"+image_urls.size());
	}

	@Override
	public void showPrevious() {
		int index = getDisplayedChild();
		if (index <= 0) {
			// 到最开始了
			return;
		}
		setInAnimation(getContext(), R.anim.slide_in_left);
		setOutAnimation(getContext(), R.anim.slide_out_right);
		
		if(index-1>=0){
			load_bitmap(index-1);
		}
		setDisplayedChild(index-1);
		if(index<image_urls.size()-1){
			remove_bitmap(index+1);
		}
		
		footer.setText(index+"/"+image_urls.size());
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		System.out.println("mindpin image switch touch");
		System.out.println(event.getAction());
		if (event.getAction() == MotionEvent.ACTION_DOWN) {
			this.down_event = MotionEvent.obtain(event);
		} else if (event.getAction() == MotionEvent.ACTION_UP) {
			float down_x = this.down_event.getX();
			float up_x = event.getX();
			if (Math.abs(down_x - up_x) > 50) {
				if (down_x > up_x) {
					// left
					showNext();
				} else {
					// right
					showPrevious();
				}
			}
		}
		return super.onTouchEvent(event);
	}

	private void load_bitmap(int index){
		String image_url = image_urls.get(index);
		ImageView image_view = (ImageView)getChildAt(index);
		ImageCache.load_cached_image(image_url, image_view);
	}
	
	private void remove_bitmap(int index){
		ImageView image_view = (ImageView)getChildAt(index);
		image_view.setBackgroundResource(R.drawable.bg_image_loading);
	}

}
