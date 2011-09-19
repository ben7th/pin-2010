package com.mindpin;

import com.mindpin.Logic.AccountManager;
import com.mindpin.Logic.Http.IntentException;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.Window;

public class LoadingActivity extends Activity implements Runnable {
	private static final int MESSAGE_LOGGED = 0;
	private static final int MESSAGE_UNLOGGED = 1;
	private static final int MESSAGE_INTENT_FAIL = 2;
	
	private Handler mhandler = new Handler(){
		public void handleMessage(android.os.Message msg) {
			switch (msg.what) {
			case MESSAGE_LOGGED:
				startActivity(new Intent(LoadingActivity.this,MainActivity.class));
				LoadingActivity.this.finish();
				break;
			case MESSAGE_UNLOGGED:
				startActivity(new Intent(LoadingActivity.this,LoginActivity.class));
				LoadingActivity.this.finish();
				break;
			case MESSAGE_INTENT_FAIL:
				startActivity(new Intent(LoadingActivity.this,MainActivity.class));
				LoadingActivity.this.finish();
				break;
			}
		};
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);  
		setContentView(R.layout.loading);

		Thread thread = new Thread(this);
		thread.setDaemon(true);
		thread.start();
	}

	public void run() {
		String email = AccountManager.get_email(this);
		String password = AccountManager.get_password(this);
		try {
			if (AccountManager.has_user_info(this)
					&& AccountManager.user_authenticate(email, password)) {
				// ��ʾ����
				Message msg = mhandler.obtainMessage();
				msg.what = MESSAGE_LOGGED;
				mhandler.sendMessage(msg);
			} else {
				// ��ʾ��¼��
				AccountManager.logout(this);
				Message msg = mhandler.obtainMessage();
				msg.what = MESSAGE_UNLOGGED;
				mhandler.sendMessage(msg);
			}
		} catch (IntentException e) {
			Message msg = mhandler.obtainMessage();
			msg.what = MESSAGE_INTENT_FAIL;
			mhandler.sendMessage(msg);
			e.printStackTrace();
		}
	}
}
