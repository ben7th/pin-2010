package com.mindpin;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class FeedDetailActivity extends Activity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.feed_detail);
		
		Bundle ex = getIntent().getExtras();
		int feed_id = ex.getInt("feed_id");
		
		TextView feed_detail_tv = (TextView)findViewById(R.id.feed_detail);
		feed_detail_tv.setText(feed_id+"");
	}
}
