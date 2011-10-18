package com.mindpin;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;

import com.mindpin.Logic.Http;
import com.mindpin.runnable.MindpinAsyncTask;
import com.mindpin.utils.BaseUtils;

public class LoginActivity extends Activity {
	private String email;
	private String password;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.login);

		bind_login_button_event();
	}

	private void bind_login_button_event() {
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
			BaseUtils.toast(R.string.login_email_valid_blank);
			return false;
		}

		if (BaseUtils.isStrBlank(password)) {
			BaseUtils.toast(R.string.login_password_valid_blank);
			return false;
		}
		
		return true;
	}
	
	//显示正在登录，并在一个线程中进行登录
	private void doLogin(){		
		new MindpinAsyncTask<String, Void, Void>(this, R.string.login_now_login){
			@Override
			public Void do_in_background(String... params) throws Exception {
				String email = params[0];
				String password = params[1];
				Http.user_authenticate(email, password);
				return null;
			}

			@Override
			public void on_success(Void v) {
				startActivity(new Intent(LoginActivity.this, MainActivity.class));
				LoginActivity.this.finish();
			}
		}.execute(email, password);
	}
}
