package com.mindpin.activity.base;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;

import com.mindpin.R;
import com.mindpin.base.activity.BaseActivity;

public class AboutActivity extends BaseActivity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.base_about);
	}
	
	public void open_mindpin_website(View view){
		Uri uri = Uri.parse("http://www.mindpin.com");
		Intent intent = new Intent(Intent.ACTION_VIEW, uri);
		startActivity(intent);
	}
}
