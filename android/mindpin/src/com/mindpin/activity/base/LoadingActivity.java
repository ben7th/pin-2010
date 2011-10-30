package com.mindpin.activity.base;

import android.os.Bundle;

import com.mindpin.R;
import com.mindpin.base.activity.MindpinBaseActivity;

//����Ӧ��ע�����
public class LoadingActivity extends MindpinBaseActivity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.base_loading);
		
		// ������Ӧ�õ���ڣ������activity���ٸ��ݵ�ǰ��¼״̬������login����main		
		open_activity(is_logged_in() ? MainActivity.class : LoginActivity.class);
		finish();
	}
}
