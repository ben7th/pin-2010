package com.mindpin;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.mindpin.Logic.Http;
import com.mindpin.utils.BaseUtils;
import com.mindpin.widget.MindpinProgressDialog;

public class LoginActivity extends Activity {
	private final static int AUTH_SUCCESS = 0; 
	private final static int AUTH_FAIL = 1; 
	private final static int INTENT_CONNECTION_FAIL = 2; 
	
	private String email;
	private String password;
	private MindpinProgressDialog progressDialog;
	
	private Handler mhandler = new Handler(){
		public void handleMessage(android.os.Message msg) {
			progressDialog.dismiss();
			
			switch (msg.what) {
			
				case AUTH_SUCCESS:
					startActivity(new Intent(LoginActivity.this,
							MainActivity.class));
					LoginActivity.this.finish();
					break;
					
				case AUTH_FAIL:
					Toast.makeText(getApplicationContext(), R.string.login_auth_fail,
							Toast.LENGTH_SHORT).show();
					break;
					
				case INTENT_CONNECTION_FAIL:
					Toast.makeText(getApplicationContext(), R.string.app_intent_connection_fail,
							Toast.LENGTH_SHORT).show();
					break;
			}
		};
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.login);

		Button login_button = (Button)findViewById(R.id.login_button);
		login_button.setOnClickListener(new OnClickListener() {

			public void onClick(View v) {
				prepareEmailAndPassword();				
				if(isParamsValid()){
					doLogin();
				}
			}
		});
	}
	
	//获取邮箱，密码字符串。作准备。
	private void prepareEmailAndPassword(){
		EditText email_et = (EditText)findViewById(R.id.email_et);
		EditText password_et = (EditText)findViewById(R.id.password_et);
		email = email_et.getText().toString();
		password = password_et.getText().toString();
	}
	
	//参数检查
	private boolean isParamsValid(){
		
		//邮箱，密码不可以空
		if (BaseUtils.isStrBlank(email)) {
			Toast.makeText(
				getApplicationContext(), 
				R.string.login_email_valid_blank,
				Toast.LENGTH_SHORT
			).show();
			return false;
		}

		if (BaseUtils.isStrBlank(password)) {
			Toast.makeText(
				getApplicationContext(), 
				R.string.login_password_valid_blank,
				Toast.LENGTH_SHORT
			).show();
			return false;
		}
		
		return true;
	}
	
	//显示正在登录，并在一个线程中进行登录
	private void doLogin(){
		String process_dialog_message = getResources().getString(R.string.login_now_login);
		progressDialog = MindpinProgressDialog.show(LoginActivity.this,process_dialog_message);
		Thread thread = new Thread(new Runnable() {
			public void run() {
				user_authenticate();
			}
		});
		thread.setDaemon(true);
		thread.start();
	}

	private void user_authenticate() {
		boolean auth = false;
		Message msg = mhandler.obtainMessage();
		
		try {
			auth = Http.user_authenticate(email, password);
			msg.what = auth ? AUTH_SUCCESS : AUTH_FAIL;
		} catch (Exception e) {
			msg.what = INTENT_CONNECTION_FAIL;
			e.printStackTrace();
		} finally {
			mhandler.sendMessage(msg);
		}
	}
}
