package com.mindpin.activity.contacts;

import java.util.ArrayList;
import android.os.Bundle;
import android.widget.ListView;
import com.mindpin.R;
import com.mindpin.Logic.Http;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.base.task.MindpinAsyncTask;
import com.mindpin.beans.Following;
import com.mindpin.widget.adapter.FollowingListAdapter;

public class FollowingListActivity extends MindpinBaseActivity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.following_list);
		load_list_data();
	}

	private void load_list_data() {
		new MindpinAsyncTask<Void, Void, ArrayList<Following>>(this,"’˝‘⁄‘ÿ»Î...") {
			@Override
			public ArrayList<Following> do_in_background(Void... params)
					throws Exception {
				return Http.get_current_user_followings();
			}

			@Override
			public void on_success(ArrayList<Following> followings) {
				ListView following_list = (ListView)findViewById(R.id.following_list);
				FollowingListAdapter adapter = new FollowingListAdapter(followings);
				following_list.setAdapter(adapter);
			}
		}.execute();
	}
}
