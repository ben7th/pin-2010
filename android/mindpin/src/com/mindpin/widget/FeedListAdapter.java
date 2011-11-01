package com.mindpin.widget;

import java.lang.ref.SoftReference;
import java.util.ArrayList;
import java.util.HashMap;

import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.text.Html;
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
import com.mindpin.base.utils.BaseUtils;
import com.mindpin.cache.FeedImageCache;
import com.mindpin.database.Feed;

public class FeedListAdapter extends BaseAdapter {
	private ArrayList<Feed> feeds;
	private HashMap<Integer, SoftReference<View>> cache_views = new HashMap<Integer, SoftReference<View>>();

	public FeedListAdapter(ArrayList<Feed> feeds) {
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
		View view = MindpinApplication.inflate(
				R.layout.feed_list_item_more_photos, parent, false);
		
		set_photos(view, feed);
		set_basic_info(view, feed);

		return view;
	}

	private View create_single_photo_view(Feed feed, ViewGroup parent) {
		View view = MindpinApplication.inflate(
				R.layout.feed_list_item_single_photo, parent, false);

		set_single_photo(view, feed);
		set_basic_info(view, feed);
		return view;
	}

	private View create_no_photo_view(Feed feed, ViewGroup parent) {
		View view = MindpinApplication.inflate(
				R.layout.feed_list_item_no_photo, parent, false);
		
		set_basic_info(view, feed);
		return view;
	}
	
	private void set_single_photo(View view, Feed feed){
		ImageView image_view = (ImageView) view.findViewById(R.id.feed_photo);
		String photo_url = feed.photos_thumbnail.get(0);
		image_view.setAdjustViewBounds(true);

		FeedImageCache.load_cached_image(photo_url, image_view);
	}
	
	private void set_photos(View view, Feed feed) {
		ArrayList<String> photo_urls = feed.photos_thumbnail;
		LinearLayout feed_photos = (LinearLayout) view
				.findViewById(R.id.feed_photos);

		for (String photo_url : photo_urls) {
			ImageView image_view = new ImageView(MindpinApplication.context);
			image_view.setAdjustViewBounds(true); // 设置这个使得图片缩放后内容合适
			Bitmap b = ((BitmapDrawable) MindpinApplication.context
					.getResources().getDrawable(R.drawable.img_loading))
					.getBitmap();
			int size_width = BaseUtils.dp_to_px(84);
			LayoutParams lp = new LayoutParams(size_width, size_width);
			lp.rightMargin = BaseUtils.dp_to_px(4); // 3x86 + 2x2 = 3x84+2x4
			lp.bottomMargin = BaseUtils.dp_to_px(9);
			image_view.setLayoutParams(lp);
			image_view.setImageBitmap(b);
			feed_photos.addView(image_view);

			FeedImageCache.load_cached_image(photo_url, image_view);
		}
	}
	
	
	private void set_basic_info(View view, Feed feed){
		set_id(view, feed);
		set_title(view, feed);
		set_detail(view, feed);
		
		set_user_avatar(view, feed);
		set_user_name(view, feed);
		set_updated_at(view, feed);
	}
	
	private void set_id(View view, Feed feed){
		TextView id_textview = (TextView) view.findViewById(R.id.feed_id);
		id_textview.setText(feed.feed_id + "");
	}
	
	private void set_title(View view, Feed feed){
		TextView title_textview = (TextView) view.findViewById(R.id.feed_title);
		
		if (BaseUtils.is_str_blank(feed.title)) {
			title_textview.setVisibility(View.GONE);
		} else {
			title_textview.setText(feed.title);
			// title_textview.getPaint().setFakeBoldText(true);
		}
	}
	
	private void set_detail(View view, Feed feed) {
		TextView detail_textview = (TextView) view.findViewById(R.id.feed_detail);
		
		if (BaseUtils.is_str_blank(feed.detail)) {
			detail_textview.setVisibility(View.GONE);
		} else {

			detail_textview.setText(Html.fromHtml(feed.detail));
		}
	}
	
	private void set_user_avatar(View view, Feed feed){
		ImageView user_avatar = (ImageView) view.findViewById(R.id.user_avatar);
		FeedImageCache.load_cached_image(feed.user_avatar_url, user_avatar);
	}
	
	private void set_user_name(View view, Feed feed){
		TextView user_name_textview = (TextView) view.findViewById(R.id.user_name);
		user_name_textview.setText(feed.user_name);
	}
	
	private void set_updated_at(View view, Feed feed){
		TextView updated_at_textview = (TextView) view.findViewById(R.id.updated_at);
		updated_at_textview.setText(BaseUtils.date_string(feed.updated_at));
	}

}
