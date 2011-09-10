package com.mindpin;

import java.util.HashMap;
import java.util.List;
import com.mindpin.Logic.Http;
import com.mindpin.Logic.Http.IntentException;
import android.app.Activity;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.os.Handler;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.Toast;

public class CollectionFeedListActivity extends Activity {
	protected static final String EXTRA_COLLECTION_ID = "collection_id";
	protected static final int MESSAGE_INTENT_CONNECTION_FAIL = 0;
	protected static final int MESSAGE_READ_FEED_LIST_SUCCESS = 1;
	private ProgressDialog progress_dialog;
	private List<HashMap<String, Object>> feeds;
	private ListView feed_list_lv;
	private Handler mhandler = new Handler(){
		public void handleMessage(android.os.Message msg) {
			switch (msg.what) {
			case MESSAGE_INTENT_CONNECTION_FAIL:
				Toast.makeText(getApplicationContext(),R.string.intent_connection_fail,
						Toast.LENGTH_SHORT).show();
				break;
			case MESSAGE_READ_FEED_LIST_SUCCESS:
				SimpleAdapter sa = new SimpleAdapter(CollectionFeedListActivity.this, 
						feeds, R.layout.feed_item,
						new String[]{"id","title"}, 
						new int[]{R.id.feed_id,R.id.feed_title});
				feed_list_lv.setAdapter(sa);
				break;
			}
			progress_dialog.dismiss();
		};
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.collection_feed_list);
		int id = getIntent().getIntExtra(EXTRA_COLLECTION_ID, 0);
		progress_dialog = ProgressDialog.show(this,
				"","正在读取数据...");
		
		feed_list_lv = (ListView)findViewById(R.id.feed_list);
		
		Thread thread = new Thread(new ReadCollectionFeedListRunnable(id));
		thread.setDaemon(true);
		thread.start();
	}
	
	public class ReadCollectionFeedListRunnable implements Runnable {
		private int id;
		public ReadCollectionFeedListRunnable(int id){
			this.id = id;
		}
		@Override
		public void run() {
			try {
				feeds = Http.get_collection_feeds(id);
				mhandler.sendEmptyMessage(MESSAGE_READ_FEED_LIST_SUCCESS);
			} catch (IntentException e) {
				mhandler.sendEmptyMessage(MESSAGE_INTENT_CONNECTION_FAIL);
			}
		}
	}
}
