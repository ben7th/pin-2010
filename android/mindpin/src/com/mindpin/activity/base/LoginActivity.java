package com.mindpin.activity.base;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;

import com.mindpin.R;
import com.mindpin.Logic.Http;
import com.mindpin.base.task.MindpinAsyncTask;
import com.mindpin.base.utils.BaseUtils;

public class LoginActivity extends Activity {
	private String email;
	private String password;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.base_login);
	}
	
	public void login_button_click(View view){
		prepareEmailAndPassword();				
		if(isParamsValid()){
			doLogin();
		}
	}
	
	//��ȡ���䣬�����ַ�������׼����
	private void prepareEmailAndPassword(){
		EditText email_et = (EditText)findViewById(R.id.email_et);
		EditText password_et = (EditText)findViewById(R.id.password_et);
		email = email_et.getText().toString();
		password = password_et.getText().toString();
	}
	
	//�������
	private boolean isParamsValid(){
		
		//���䣬���벻���Կ�
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
	
	//��ʾ���ڵ�¼������һ���߳��н��е�¼
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
