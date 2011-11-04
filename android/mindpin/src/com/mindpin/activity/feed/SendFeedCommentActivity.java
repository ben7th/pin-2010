package com.mindpin.activity.feed;

import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import com.mindpin.R;
import com.mindpin.Logic.Http;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.base.task.MindpinAsyncTask;
import com.mindpin.base.utils.BaseUtils;

public class SendFeedCommentActivity extends MindpinBaseActivity {
	public static final String EXTRA_NAME_FEED_ID = "feed_id";
	private String feed_id;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.send_feed_comment);
		this.feed_id = getIntent().getStringExtra(EXTRA_NAME_FEED_ID);
		
		Button send_feed_comment_bn = (Button)findViewById(R.id.send_feed_comment_bn);
		send_feed_comment_bn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				send_feed_comment();
			}
		});
	}
	
	private void send_feed_comment(){
		EditText feed_comment_et = (EditText)findViewById(R.id.feed_comment_et);
		String comment = feed_comment_et.getText().toString();
		
		if(BaseUtils.is_str_blank(comment)){
			BaseUtils.toast("评论内容不能为空");
			return;
		}
		
		new MindpinAsyncTask<String, Void, Boolean>(this,"正在发送...") {
			@Override
			public Boolean do_in_background(String... params) throws Exception {
				String feed_id = params[0];
				String comment = params[1];
				return Http.add_feed_commment(feed_id, comment);
			}

			@Override
			public void on_success(Boolean result) {
				if(result){
					BaseUtils.toast("评论发送成功");
					SendFeedCommentActivity.this.finish();
				}else{
					BaseUtils.toast("评论发送失败，请稍后重试");
				}
			}
		}.execute(feed_id,comment);
	}
}
