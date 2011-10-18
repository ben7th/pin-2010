package com.mindpin.activity.base;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Window;

import com.mindpin.R;
import com.mindpin.Logic.AccountManager;

public class LoadingActivity extends Activity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);  
		setContentView(R.layout.loading);
		
		// ������Ӧ�õ���ڣ������activity���ٸ��ݵ�ǰ��¼״̬������login����main
		startActivity(
			new Intent(
				LoadingActivity.this, 
				AccountManager.is_logged_in() ? MainActivity.class : LoginActivity.class
			)
		);
		LoadingActivity.this.finish();
	}

}
