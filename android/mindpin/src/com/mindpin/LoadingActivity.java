package com.mindpin;

import com.mindpin.Logic.AccountManager;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Window;

public class LoadingActivity extends Activity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);  
		setContentView(R.layout.loading);
		
		if(AccountManager.is_logged_in()){
			startActivity(new Intent(LoadingActivity.this,MainActivity.class));
			LoadingActivity.this.finish();
		}else{
			startActivity(new Intent(LoadingActivity.this, LoginActivity.class));
			LoadingActivity.this.finish();
		}
	}

}
