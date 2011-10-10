package com.mindpin;

import com.mindpin.Logic.Http;
import com.mindpin.Logic.Http.IntentException;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class LoginActivity extends Activity {
	private final static int AUTH_SUCCESS = 0; 
	private final static int AUTH_FAIL = 1; 
	private final static int INTENT_CONNECTION_FAIL = 2; 
	
	private EditText email_et;
	private EditText password_et;
	
	private String email;
	private String password;
	private ProgressDialog progressDialog;
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
				Toast.makeText(getApplicationContext(), R.string.auth_fail,
						Toast.LENGTH_SHORT).show();
				break;
			case INTENT_CONNECTION_FAIL:
				Toast.makeText(getApplicationContext(), R.string.intent_connection_fail,
						Toast.LENGTH_SHORT).show();
				break;
			}
		};
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.login);

		Button login_bn = (Button) findViewById(R.id.login_bn);
		login_bn.setOnClickListener(new OnClickListener() {

			public void onClick(View v) {
				email_et = (EditText) findViewById(R.id.email_et);
				password_et = (EditText) findViewById(R.id.password_et);
				email = email_et.getText().toString();
				password = password_et.getText().toString();

				if (email == null || "".equals(email)) {
					Toast.makeText(getApplicationContext(), R.string.email_valid_blank,
							Toast.LENGTH_SHORT).show();
					return;
				}

				if (password == null || "".equals(password)) {
					Toast.makeText(getApplicationContext(), R.string.password_valid_blank,
							Toast.LENGTH_SHORT).show();
					return;
				}
				progressDialog = ProgressDialog.show(LoginActivity.this,
						"","µÇÂ¼ÖÐ...");
				
				Thread thread = new Thread(new Runnable() {
					public void run() {
						user_authenticate(email, password);
					}
				});
				thread.setDaemon(true);
				thread.start();
			}
		});
	}

	private void user_authenticate(String email, String password) {
		boolean auth = false;
		try {
			auth = Http.user_authenticate(email, password);
			if (auth) {
				Message msg = mhandler.obtainMessage();
				msg.what = AUTH_SUCCESS;
				mhandler.sendMessage(msg);
			} else {
				Message msg = mhandler.obtainMessage();
				msg.what = AUTH_FAIL;
				mhandler.sendMessage(msg);
			}
		} catch (IntentException e) {
			Message msg = mhandler.obtainMessage();
			msg.what = INTENT_CONNECTION_FAIL;
			mhandler.sendMessage(msg);
			e.printStackTrace();
		}
	}
}
