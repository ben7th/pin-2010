package com.mindpin.widget.adapter;

import java.util.ArrayList;
import com.mindpin.R;
import com.mindpin.Logic.Http;
import com.mindpin.application.MindpinApplication;
import com.mindpin.base.utils.BaseUtils;
import com.mindpin.cache.image.ImageCache;
import com.mindpin.database.Feed;
import com.mindpin.database.FeedComment;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class ReceivedCommentListAdapter extends BaseAdapter {
	private ArrayList<FeedComment> feed_comments;

	public ReceivedCommentListAdapter(ArrayList<FeedComment> feed_comments) {
		this.feed_comments = feed_comments;
	}

	@Override
	public int getCount() {
		return feed_comments.size();
	}

	@Override
	public Object getItem(int position) {
		return feed_comments.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		FeedComment comment = feed_comments.get(position);
		convertView = generate_view_holder(convertView);
		ViewHolder view_holder = (ViewHolder)convertView.getTag();
		
		fill_with_feed_comment_data(view_holder, comment);
		
		return convertView;
	}
	
	private void fill_with_feed_comment_data(ViewHolder view_holder,
			FeedComment comment) {
		view_holder.comment_id_tv.setText(comment.comment_id+"");
		view_holder.content_tv.setText(comment.content);
		view_holder.created_at_tv.setText(BaseUtils.date_string(comment.created_at));
		
		view_holder.user_name_tv.setText(comment.user_name);
		ImageCache.load_cached_image(comment.user_logo_url,view_holder.user_logo_iv);
	}
	
	private View generate_view_holder(View convertView) {
		if(null == convertView){
			ViewHolder view_holder = new ViewHolder();
			convertView = MindpinApplication.inflate(R.layout.feed_comment_item, null);
			view_holder.comment_id_tv = (TextView)convertView.findViewById(R.id.feed_comment_id); 
			view_holder.content_tv = (TextView)convertView.findViewById(R.id.feed_comment_content);
			view_holder.user_logo_iv = (ImageView)convertView.findViewById(R.id.user_avatar);
			view_holder.user_name_tv = (TextView)convertView.findViewById(R.id.user_name);
			view_holder.created_at_tv = (TextView)convertView.findViewById(R.id.created_at);
			convertView.setTag(view_holder);
		}
		return convertView;
	}
	
	public void destroy_item(int position) {
		feed_comments.remove(position);
		this.notifyDataSetChanged();
	}

	public void load_more_data() throws Exception {
		FeedComment current_last_feed_comment = feed_comments.get(feed_comments.size() - 1);
		int comment_id = current_last_feed_comment.comment_id;
		
		ArrayList<FeedComment> more_feed_comments = Http.received_comments(
				comment_id - 1);
		for (FeedComment feed_comment : more_feed_comments) {
			feed_comments.add(feed_comment);
		}		
	}
	
	public class ViewHolder {
		public TextView comment_id_tv;
		public TextView content_tv;
		public ImageView user_logo_iv;
		public TextView user_name_tv;
		public TextView created_at_tv;
	}

}
