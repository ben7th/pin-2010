package com.mindpin.base.activity;

import com.mindpin.Logic.AccountManager;

import android.app.Activity;
import android.content.Intent;
import android.view.View;

public class MindpinBaseActivity extends Activity {
	
	// ���ڶ��� go_back ��ť�ϵ��¼�����
	final public void go_back(View view){
		this.finish();
	}
	
	// ��һ���µ�activity���˷��������򻯵���
	final public void open_activity(Class<?> cls) {
		startActivity(new Intent(getApplicationContext(), cls));
	}
	
	final public boolean is_logged_in(){
		return AccountManager.is_logged_in();
	}
}
