package com.mindpin;


import com.mindpin.Logic.AccountManager;
import com.mindpin.Logic.CameraLogic;
import com.mindpin.cache.AccountInfoCache;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends Activity {
	private final int GROUP_DEFAULT = 0;
	private final int MENU_ABOUT = 1;
	private final int MENU_LOGOUT = 2;
	
	private Intent to_new_feed;
	private Intent to_collection_list;
	private LinearLayout bn_new_feed;
	private LinearLayout bn_camera;
	private LinearLayout bn_feeds;
	private LinearLayout bn_collections;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);
		to_new_feed = new Intent(this,NewFeedActivity.class);
		to_collection_list = new Intent(this,CollectionListActivity.class);
		
		bn_new_feed = (LinearLayout)findViewById(R.id.main_bn_new_feed);
		bn_new_feed.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				startActivity(to_new_feed);
			}
		});
		
		bn_camera = (LinearLayout)findViewById(R.id.main_bn_camera);
		bn_camera.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				CameraLogic.call_sysotem_camera(MainActivity.this);
			}
		});
		
		bn_feeds = (LinearLayout)findViewById(R.id.main_bn_feeds);
		bn_feeds.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Toast.makeText(getApplicationContext(),"浏览主题正在施工中...",
						Toast.LENGTH_SHORT).show();
			}
		});
		
		bn_collections = (LinearLayout) findViewById(R.id.main_bn_collections);
		bn_collections.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				startActivity(to_collection_list);
			}
		});
		
		
		ImageView account_logo_img = (ImageView)findViewById(R.id.account_logo);
		TextView account_name_tv = (TextView)findViewById(R.id.account_name);
		account_name_tv.setText(AccountInfoCache.get_name());
		Bitmap b = BitmapFactory.decodeFile(AccountInfoCache.get_logo_path());
		account_logo_img.setImageBitmap(b);
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		menu.add(GROUP_DEFAULT, MENU_ABOUT, 0, R.string.about);
		menu.add(GROUP_DEFAULT, MENU_LOGOUT, 0, R.string.logout);
		return super.onCreateOptionsMenu(menu);
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case MENU_ABOUT:
			startActivity(new Intent(this, AboutActivity.class));
			break;
		case MENU_LOGOUT:
			AccountManager.remove_user_info(this);
			startActivity(new Intent(this, LoginActivity.class));
			this.finish();
			break;
		}

		return super.onOptionsItemSelected(item);
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(resultCode != Activity.RESULT_OK){
			return;
		}
		
		switch (requestCode) {
		case CameraLogic.REQUEST_CAPTURE:
			Intent intent = new Intent(MainActivity.this,NewFeedActivity.class);
			intent.putExtra(CameraLogic.HAS_IMAGE_CAPTURE,true);
			startActivity(intent);
			break;
		}
		super.onActivityResult(requestCode, resultCode, data);
	}
}
