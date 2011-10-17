package com.mindpin.widget;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import com.mindpin.R;
import com.mindpin.utils.BaseUtils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.LinearLayout.LayoutParams;

public class FeedListAdapter extends BaseAdapter {
	private Context context;
	private List<HashMap<String, Object>> feeds;
	private LayoutInflater mInflater;
	private HashMap<String, View> cache_views = new HashMap<String, View>();

	public FeedListAdapter(Context context,List<HashMap<String, Object>> feeds){
		this.context = context;
		this.feeds = feeds;
		this.mInflater = (LayoutInflater) this.context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
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
		HashMap<String, Object> feed = feeds.get(position);
		String id = (Integer) feed.get("id") + "";
		View view = cache_views.get(id);
		if(view == null){
			String title = (String) feed.get("title");
			String detail = (String) feed.get("detail");
			ArrayList<String> photos = (ArrayList<String>) feed.get("photos");
			switch (photos.size()) {
			case 0:
				view = create_no_photo_view(id, title, detail, parent);
				break;
			case 1:
				view = create_single_photo_view(id, title, detail,
						photos.get(0), parent);
				break;
			default:
				view = create_more_photo_view(id, title, detail, photos,
						parent);
				break;
			}
			cache_views.put(id, view); 
		}
		return view;
	}

	private View create_more_photo_view(String id, String title, String detail,
			ArrayList<String> photos, ViewGroup parent) {
		View view = mInflater.inflate(R.layout.more_photo_feed_item, parent, false);
		TextView id_tv = (TextView)view.findViewById(R.id.feed_id);
		id_tv.setText(id);
		TextView title_tv = (TextView)view.findViewById(R.id.feed_title);
		title_tv.setText(title);
		TextView detail_tv = (TextView)view.findViewById(R.id.feed_detail);
		detail_tv.setText(detail);
		
		LinearLayout feed_photos = (LinearLayout)view.findViewById(R.id.feed_photos);
		for (int i = 0; i < photos.size(); i++) {
			String photo_url = photos.get(i);
			
			ImageView img = new ImageView(context);
			img.setAdjustViewBounds(true); //设置这个使得图片缩放后内容合适
			Bitmap b = ((BitmapDrawable) context.getResources().getDrawable(
					R.drawable.img_loading)).getBitmap();
			LayoutParams lp = new LayoutParams(BaseUtils.get_px_by_dip(context,96),
					BaseUtils.get_px_by_dip(context,96));
			img.setLayoutParams(lp);
			img.setImageBitmap(b);
			feed_photos.addView(img);
			DownloadImageTask task = new DownloadImageTask(img);
			task.execute(photo_url);
		}
		
		return view;
	}

	private View create_single_photo_view(String id, String title,
			String detail, String photo_url, ViewGroup parent) {
		View view = mInflater.inflate(R.layout.single_photo_feed_item, parent, false);
		TextView id_tv = (TextView)view.findViewById(R.id.feed_id);
		id_tv.setText(id);
		TextView title_tv = (TextView)view.findViewById(R.id.feed_title);
		title_tv.setText(title);
		TextView detail_tv = (TextView)view.findViewById(R.id.feed_detail);
		detail_tv.setText(detail);
		ImageView image_iv = (ImageView)view.findViewById(R.id.feed_photo);
		DownloadImageTask task = new DownloadImageTask(image_iv);
		task.execute(photo_url);
		return view;
	}

	private View create_no_photo_view(String id, String title, String detail, ViewGroup parent) {
		View view = mInflater.inflate(R.layout.no_photo_feed_item, parent, false);
		TextView id_tv = (TextView)view.findViewById(R.id.feed_id);
		id_tv.setText(id);
		TextView title_tv = (TextView)view.findViewById(R.id.feed_title);
		title_tv.setText(title);
		TextView detail_tv = (TextView)view.findViewById(R.id.feed_detail);
		detail_tv.setText(detail);
		return view;
	}
}
