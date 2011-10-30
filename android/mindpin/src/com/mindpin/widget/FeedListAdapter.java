package com.mindpin.widget;

import java.lang.ref.SoftReference;
import java.util.ArrayList;
import java.util.HashMap;

import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.TextView;

import com.mindpin.R;
import com.mindpin.Logic.Http;
import com.mindpin.application.MindpinApplication;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.base.utils.BaseUtils;
import com.mindpin.cache.FeedImageCache;
import com.mindpin.database.Feed;

public class FeedListAdapter extends BaseAdapter {
	private ArrayList<Feed> feeds;
	private HashMap<Integer, SoftReference<View>> cache_views = new HashMap<Integer, SoftReference<View>>();

	public FeedListAdapter(MindpinBaseActivity activity, ArrayList<Feed> feeds) {
		this.feeds = feeds;
	}

	@Override
	public int getCount() {
		return feeds.size();
	}

	@Override
	public Object getItem(int position) {
		return feeds.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		Feed feed = feeds.get(position);
		int feed_id = feed.feed_id;

		View view = get_view_from_cache_views(feed_id);

		if (null != view) {
			return view;
		}

		switch (feed.photos_middle.size()) {
		case 0:
			view = create_no_photo_view(feed, parent);
			break;
		case 1:
			view = create_single_photo_view(feed, parent);
			break;
		default:
			view = create_more_photo_view(feed, parent);
			break;
		}
		cache_views.put(feed_id, new SoftReference<View>(view));
		return view;
	}

	private View get_view_from_cache_views(int feed_id) {
		SoftReference<View> soft_ref = cache_views.get(feed_id);
		return null == soft_ref ? null : soft_ref.get();
	}

	public void load_more_data() throws Exception {
		Feed feed = feeds.get(feeds.size() - 1);
		int id = feed.feed_id;
		ArrayList<Feed> more_feeds = Http.get_home_timeline_feeds(id - 1);
		for (Feed feed2 : more_feeds) {
			feeds.add(feed2);
		}
	}

	private View create_more_photo_view(Feed feed, ViewGroup parent) {
		View view = MindpinApplication.inflate(R.layout.feed_list_item_more_photos,
				parent, false);
		TextView id_tv = (TextView) view.findViewById(R.id.feed_id);
		id_tv.setText(feed.feed_id + "");
		TextView title_tv = (TextView) view.findViewById(R.id.feed_title);
		title_tv.setText(feed.title);
		TextView detail_tv = (TextView) view.findViewById(R.id.feed_detail);
		detail_tv.setText(feed.detail);
		ArrayList<String> photos = feed.photos_middle;
		LinearLayout feed_photos = (LinearLayout) view
				.findViewById(R.id.feed_photos);
		for (int i = 0; i < photos.size(); i++) {
			if (i > 5) {
				break;
			}
			String photo_url = photos.get(i);

			ImageView img = new ImageView(MindpinApplication.context);
			img.setAdjustViewBounds(true); // 设置这个使得图片缩放后内容合适
			Bitmap b = ((BitmapDrawable) MindpinApplication.context.getResources().getDrawable(
					R.drawable.img_loading)).getBitmap();
			LayoutParams lp = new LayoutParams(BaseUtils.get_px_by_dip(96),
					BaseUtils.get_px_by_dip(96));
			img.setLayoutParams(lp);
			img.setImageBitmap(b);
			feed_photos.addView(img);

			FeedImageCache.load_cached_image(photo_url, img);
		}

		return view;
	}

	private View create_single_photo_view(Feed feed, ViewGroup parent) {
		View view = MindpinApplication.inflate(R.layout.feed_list_item_single_photo,
				parent, false);
		TextView id_tv = (TextView) view.findViewById(R.id.feed_id);
		id_tv.setText(feed.feed_id + "");
		TextView title_tv = (TextView) view.findViewById(R.id.feed_title);
		title_tv.setText(feed.title);
		TextView detail_tv = (TextView) view.findViewById(R.id.feed_detail);
		detail_tv.setText(feed.detail);
		ImageView image_view = (ImageView) view.findViewById(R.id.feed_photo);
		String photo_url = feed.photos_middle.get(0);

		FeedImageCache.load_cached_image(photo_url, image_view);
		return view;
	}

	private View create_no_photo_view(Feed feed, ViewGroup parent) {
		View view = MindpinApplication.inflate(R.layout.feed_list_item_no_photo, parent,
				false);
		TextView id_tv = (TextView) view.findViewById(R.id.feed_id);
		id_tv.setText(feed.feed_id + "");
		TextView title_tv = (TextView) view.findViewById(R.id.feed_title);
		title_tv.setText(feed.title);
		TextView detail_tv = (TextView) view.findViewById(R.id.feed_detail);
		detail_tv.setText(feed.detail);
		return view;
	}

}
