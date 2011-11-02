package com.mindpin.widget.adapter;

import java.util.ArrayList;

import android.text.Html;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.mindpin.R;
import com.mindpin.Logic.Http;
import com.mindpin.application.MindpinApplication;
import com.mindpin.base.utils.BaseUtils;
import com.mindpin.cache.ImageCache;
import com.mindpin.database.Feed;

public class FeedListAdapter extends BaseAdapter {
	private ArrayList<Feed> feeds;
	
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
	
	// 读取更多主题，点击列表下方时调用
	public void load_more_data() throws Exception {
		Feed current_last_feed = feeds.get(feeds.size() - 1);
		int feed_id = current_last_feed.feed_id;
		
		ArrayList<Feed> more_feeds = Http.get_home_timeline_feeds(feed_id - 1);
		for (Feed feed : more_feeds) {
			feeds.add(feed);
		}
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		Feed feed = feeds.get(position);
		convertView = generate_view_holder(convertView);
		
		ViewHolder view_holder = (ViewHolder)convertView.getTag();
		fill_with_feed_data(view_holder, feed);
		
		return convertView;
	}

	private View generate_view_holder(View convertView) {
		if(null == convertView){
			ViewHolder view_holder = new ViewHolder();
			convertView = MindpinApplication.inflate(R.layout.feed_list_item, null);
			
			view_holder.id_textview 	= (TextView) convertView.findViewById(R.id.feed_id);
			view_holder.title_textview  = (TextView) convertView.findViewById(R.id.feed_title);
			view_holder.detail_textview = (TextView) convertView.findViewById(R.id.feed_detail);
			
			view_holder.user_name_textview 	  = (TextView) convertView.findViewById(R.id.user_name);
			view_holder.user_avatar_imageview = (ImageView) convertView.findViewById(R.id.user_avatar);
			view_holder.updated_at_textview   = (TextView) convertView.findViewById(R.id.updated_at);
			
			view_holder.feed_photos_1st = (ImageView) convertView.findViewById(R.id.feed_photos_1st);
			view_holder.feed_photos_2nd = (ImageView) convertView.findViewById(R.id.feed_photos_2nd);
			view_holder.feed_photos_3rd = (ImageView) convertView.findViewById(R.id.feed_photos_3rd);
			view_holder.feed_one_photo  = (ImageView) convertView.findViewById(R.id.feed_one_photo);
			
			convertView.setTag(view_holder);
		}
		
		return convertView;
	}
	
	private void fill_with_feed_data(ViewHolder view_holder, Feed feed){
		set_basic_info(view_holder, feed);
		
		switch (feed.photos_middle.size()) {
		case 0:
			clear_photos(view_holder);
			break;
		case 1:
			set_one_photo(view_holder, feed);
			break;
		default:
			set_photos(view_holder, feed);
			break;
		}
		
	}
	
	private void set_basic_info(ViewHolder view_holder, Feed feed){
		set_id(view_holder, feed);
		set_title(view_holder, feed);
		set_detail(view_holder, feed);
		
		set_user_avatar(view_holder, feed);
		set_user_name(view_holder, feed);
		set_updated_at(view_holder, feed);
	}
	
	private void set_id(ViewHolder view_holder, Feed feed){
		view_holder.id_textview.setText(feed.feed_id + "");
	}
	
	private void set_title(ViewHolder view_holder, Feed feed){
		TextView title_textview = view_holder.title_textview;
		
		if (BaseUtils.is_str_blank(feed.title)) {
			title_textview.setVisibility(View.GONE);
		} else {
			title_textview.setText(feed.title);
			title_textview.setVisibility(View.VISIBLE);
			// title_textview.getPaint().setFakeBoldText(true);
		}
	}
	
	private void set_detail(ViewHolder view_holder, Feed feed) {
		TextView detail_textview = view_holder.detail_textview;
		
		if (BaseUtils.is_str_blank(feed.detail)) {
			detail_textview.setVisibility(View.GONE);
		} else {
			detail_textview.setText(Html.fromHtml(feed.detail));
			detail_textview.setVisibility(View.VISIBLE);
		}
	}
	
	private void set_user_avatar(ViewHolder view_holder, Feed feed){
		view_holder.user_avatar_imageview.setImageResource(R.drawable.user_default_avatar_normal);
		ImageCache.load_cached_image(feed.user_avatar_url, view_holder.user_avatar_imageview);
	}
	
	private void set_user_name(ViewHolder view_holder, Feed feed){
		view_holder.user_name_textview.setText(feed.user_name);
	}
	
	private void set_updated_at(ViewHolder view_holder, Feed feed){
		view_holder.updated_at_textview.setText(BaseUtils.date_string(feed.updated_at));
	}
	
	private void clear_photos(ViewHolder view_holder){
		view_holder.feed_photos_1st.setVisibility(View.GONE);
		view_holder.feed_photos_2nd.setVisibility(View.GONE);
		view_holder.feed_photos_3rd.setVisibility(View.GONE);
		view_holder.feed_one_photo.setVisibility(View.GONE);
	}
	
	private void set_one_photo(ViewHolder view_holder, Feed feed){
		clear_photos(view_holder);
		
		ImageView image_view = view_holder.feed_one_photo;
		image_view.setImageBitmap(null);
		image_view.setVisibility(View.VISIBLE);
		
		double photo_ratio = feed.photos_ratio.get(0);
		LayoutParams lp = image_view.getLayoutParams();
		lp.height = BaseUtils.dp_to_px((int)(260*photo_ratio));
		image_view.setLayoutParams(lp);
		
		String photo_url = feed.photos_large.get(0);
		ImageCache.load_cached_image(photo_url, image_view);
	}
	
	private void set_photos(ViewHolder view_holder, Feed feed) {
		clear_photos(view_holder);

		int count = feed.photos_thumbnail.size();
		for (int i = 0; i < count; i++) {
			String photo_url = feed.photos_thumbnail.get(i);
			
			if(0 == i) set_thumbnail(photo_url, view_holder.feed_photos_1st);
			if(1 == i) set_thumbnail(photo_url, view_holder.feed_photos_2nd);
			if(2 == i) set_thumbnail(photo_url, view_holder.feed_photos_3rd);
			if(3 <= i) break;
		}
	}
	
	private void set_thumbnail(String photo_url, ImageView image_view){
		image_view.setImageBitmap(null);
		image_view.setVisibility(View.VISIBLE);
		ImageCache.load_cached_image(photo_url, image_view);
	}
	
	private final class ViewHolder {  
		public TextView id_textview;
		public TextView title_textview;
		public TextView detail_textview;
		
		public TextView user_name_textview;
		public ImageView user_avatar_imageview;
		public TextView updated_at_textview;
		
        public ImageView feed_photos_1st;
        public ImageView feed_photos_2nd;
        public ImageView feed_photos_3rd;
        public ImageView feed_one_photo;
    } 

}
