package com.mindpin.widget;

import java.util.ArrayList;

import com.mindpin.R;
import com.mindpin.application.MindpinApplication;
import com.mindpin.cache.FeedImageCache;
import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.ViewAnimator;

public class MindpinImageSwitcher extends ViewAnimator {
	private ArrayList<String> image_urls;
	private int start_index;
	private int end_index;

	private int which_child = 0;
	private MotionEvent down_event;

	public MindpinImageSwitcher(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public MindpinImageSwitcher(Context context) {
		super(context);
	}

	public void load_urls(ArrayList<String> image_urls) {
		this.image_urls = image_urls;
		this.start_index = 0;
		this.end_index = 10;
		if (image_urls.size() - 1 < end_index) {
			end_index = image_urls.size() - 1;
		}
		load_part_image();
		setDisplayedChild(0);
	}

	private void load_part_image() {
		for (int i = start_index; i <= end_index; i++) {
			String image_url = image_urls.get(i);
			ImageView image_view = new ImageView(getContext());
			FeedImageCache.load_cached_image(image_url, image_view);
			addView(image_view, i);
		}
	}

	@Override
	public void showNext() {
		if (which_child >= getChildCount() - 1) {
			// 到最后了
			return;
		}
		int next = which_child + 1;
		setInAnimation(getContext(), R.anim.slide_in_right);
		setOutAnimation(getContext(), R.anim.slide_out_left);
		setDisplayedChild(next);
		System.out.println("index " +which_child);

		if (next >= 6 && image_urls.size() - 1 > end_index) {
			// 增加新的图片
			String image_url = image_urls.get(end_index + 1);
			ImageView image_view = new ImageView(MindpinApplication.context);
			FeedImageCache.load_cached_image(image_url, image_view);
			addView(image_view);
			// 删除一个旧的图片
			removeViewAt(0);
			// 角标向后移动 1
			start_index++;
			end_index++;
			which_child--;
		}
	}

	@Override
	public void showPrevious() {
		if (which_child <= 0) {
			// 到最开始了
			return;
		}
		int previous = which_child - 1;
		setInAnimation(getContext(), R.anim.slide_in_left);
		setOutAnimation(getContext(), R.anim.slide_out_right);
		setDisplayedChild(previous);
		System.out.println("index " +which_child);

		if (start_index != 0 && previous <= 5) {
			// 增加新的图片
			String image_url = image_urls.get(start_index - 1);
			ImageView image_view = new ImageView(MindpinApplication.context);
			FeedImageCache.load_cached_image(image_url, image_view);

			ArrayList<View> views = get_children();
			System.out.println("count " +  views.size());
			views.remove(views.size() - 1);
			removeAllViews();

			addView(image_view);
			for (View view : views) {
				addView(view);
			}
			// 角标向前移动 1
			start_index--;
			end_index--;
			which_child++;
		}

	}

	@Override
	public void setDisplayedChild(int whichChild) {
		this.which_child = whichChild;
		super.setDisplayedChild(whichChild);
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

	private ArrayList<View> get_children() {
		ArrayList<View> views = new ArrayList<View>();
		for (int i = 0; i < getChildCount(); i++) {
			views.add(getChildAt(i));
		}
		return views;
	}

}
