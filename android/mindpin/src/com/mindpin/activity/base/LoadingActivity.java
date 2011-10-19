package com.mindpin.activity.base;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.mindpin.R;
import com.mindpin.Logic.AccountManager;

public class LoadingActivity extends Activity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.base_loading);
		
		// 这里是应用的入口，进入该activity后再根据当前登录状态，进入login或是main
		startActivity(
			new Intent(
				LoadingActivity.this, 
				AccountManager.is_logged_in() ? MainActivity.class : LoginActivity.class
			)
		);
		LoadingActivity.this.finish();
	}

}
