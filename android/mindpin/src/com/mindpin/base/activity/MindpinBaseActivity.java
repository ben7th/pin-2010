package com.mindpin.base.activity;

import com.mindpin.Logic.AccountManager;

import android.app.Activity;
import android.content.Intent;
import android.view.View;

public class MindpinBaseActivity extends Activity {
	
	// 绑定在顶栏 go_back 按钮上的事件处理
	final public void go_back(View view){
		this.finish();
	}
	
	// 打开一个新的activity，此方法用来简化调用
	final public void open_activity(Class<?> cls) {
		startActivity(new Intent(getApplicationContext(), cls));
	}
	
	final public boolean is_logged_in(){
		return AccountManager.is_logged_in();
	}
}
