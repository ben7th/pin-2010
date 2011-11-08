package com.mindpin.widget.adapter;

import java.util.ArrayList;

import com.mindpin.R;
import com.mindpin.application.MindpinApplication;
import com.mindpin.beans.Following;
import com.mindpin.cache.image.ImageCache;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class FollowingListAdapter extends BaseAdapter {
	private ArrayList<Following> followings;

	public FollowingListAdapter(ArrayList<Following> followings) {
		this.followings = followings;
	}

	@Override
	public int getCount() {
		return followings.size();
	}

	@Override
	public Object getItem(int position) {
		return followings.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		Following following = followings.get(position);
		convertView = generate_view_holder(convertView);
		
		ViewHolder view_holder = (ViewHolder)convertView.getTag();
		fill_with_following_data(view_holder, following);
		
		return convertView;
	}
	
	
	
	private void fill_with_following_data(ViewHolder view_holder,
			Following following) {
		view_holder.user_id_textview.setText(following.user_id+"");
		view_holder.user_name_textview.setText(following.name);
		view_holder.user_sign_textview.setText(following.sign);
		
		ImageView image_view = view_holder.user_avatar_imageview;
		image_view.setImageResource(R.drawable.user_default_avatar_normal);
		image_view.setVisibility(View.VISIBLE);
		ImageCache.load_cached_image(following.avatar_url, image_view);
		
		if(following.v2_activate){
			view_holder.v2_activate_textview.setText("ÒÑ¼¤»î");
		}else{
			view_holder.v2_activate_textview.setText("Î´¼¤»î");
		}
		
	}

	private View generate_view_holder(View convertView) {
		if(null == convertView){
			convertView = MindpinApplication.inflate(R.layout.following_list_item, null);
			ViewHolder view_holder = new ViewHolder();
			
			view_holder.user_id_textview = (TextView)convertView.findViewById(R.id.user_id);
			view_holder.user_name_textview = (TextView)convertView.findViewById(R.id.user_name);
			view_holder.user_sign_textview = (TextView)convertView.findViewById(R.id.user_sign);
			view_holder.user_avatar_imageview = (ImageView)convertView.findViewById(R.id.user_avatar);
			view_holder.v2_activate_textview = (TextView)convertView.findViewById(R.id.v2_activate);
			
			convertView.setTag(view_holder);
		}
		
		return convertView;
	}



	private final class ViewHolder {
		public TextView user_id_textview;
		public TextView user_name_textview;
		public ImageView user_avatar_imageview;
		public TextView user_sign_textview;
		public TextView v2_activate_textview;
    } 
}
