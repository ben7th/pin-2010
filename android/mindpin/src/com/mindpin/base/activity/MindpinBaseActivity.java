package com.mindpin.base.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;

import com.mindpin.Logic.AccountManager;
import com.mindpin.activity.base.LoginActivity;
import com.mindpin.cache.image.ImageCache;
import com.mindpin.model.AccountUser;

abstract public class MindpinBaseActivity extends Activity {
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		ActivitiesStackSingleton.tidy_and_push_activity(this);
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		ActivitiesStackSingleton.remove_activity(this);
	}
	
	
	// �ر�����activity�������´�login
	final public void restart_to_login(){
		ActivitiesStackSingleton.clear_activities_stack();
		open_activity(LoginActivity.class);
	}

	// ���ڶ��� go_back ��ť�ϵ��¼�����
	final public void go_back(View view) {
		on_go_back();
		this.finish();
	}

	// ��һ���µ�activity���˷��������򻯵���
	final public void open_activity(Class<?> cls) {
		startActivity(new Intent(getApplicationContext(), cls));
	}

	final public boolean is_logged_in() {
		return AccountManager.is_logged_in();
	}

	final public AccountUser current_user() {
		return AccountManager.current_user();
	}

	// ���ӣ���������
	public void on_go_back() {
	};
	
	
	// ���Դӻ����ȡһ��ͼƬ�ŵ�ָ����view
	final public void load_cached_image(String image_url, ImageView image_view){
		ImageCache.load_cached_image(image_url, image_view);
	}

}
