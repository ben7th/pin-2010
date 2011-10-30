package com.mindpin.base.activity;

import java.util.Stack;

import android.app.Activity;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;

import com.mindpin.Logic.AccountManager;
import com.mindpin.activity.base.LoginActivity;
import com.mindpin.cache.FeedImageCache;
import com.mindpin.database.User;
import com.mindpin.receiver.BroadcastReceiverConstants;

public class MindpinBaseActivity extends Activity {
	private static Stack<MindpinBaseActivity> activities_stack = new Stack<MindpinBaseActivity>();

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		deal_activities_stack();
		
		registerReceiver(FeedImageCache.syn_image_broadcast_receiver, new IntentFilter(
				BroadcastReceiverConstants.ACTION_SYN_FEED_HOME_LINE_IMAGE));
	}

	private void deal_activities_stack() {
		Class<?> cls = this.getClass();
		
		//System.out.println(cls + "create");
		//System.out.println("����ǰ��activities��ջ����"+ activities_stack.size() +"��ʵ��");
		
		// �ȱ���������ͬ���͵� activitiy��������ڣ���������ر�����activity֮�������ʵ��
		// �Ȳ���������ͬ��ʵ�����±�
		int index = -1;
		int size = activities_stack.size();
		for (int i = 0; i < size; i++) {
			MindpinBaseActivity activity = activities_stack.get(i);
			if (cls == activity.getClass()) {
				index = i;
				break;
			}
		}
		
		// ����ҵ������֮
		if(index > -1){
			int pops_count = size - index;
			for (int i = 0; i < pops_count; i++) {
				MindpinBaseActivity item = activities_stack.pop();
				item.finish();
			}
		}
		activities_stack.push(this);
		
		//System.out.println("�����activities��ջ����"+ activities_stack.size() +"��ʵ��");
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		//System.out.println(this.getClass().toString() + "destroy");
		//System.out.println("����ǰ��activities��ջ����"+ activities_stack.size() +"��ʵ��");
		activities_stack.remove(this);
		//System.out.println("����ǰ��activities��ջ����"+ activities_stack.size() +"��ʵ��");
		unregisterReceiver(FeedImageCache.syn_image_broadcast_receiver);
	}
	
	// �ر����ж�ջ�е�activity
	final private void clear_activities_stack(){
		int size = activities_stack.size();
		for(int i=0;i<size;i++){
			MindpinBaseActivity activity = activities_stack.pop();
			activity.finish();
		}
	}
	
	// �ر�����activity�������´�login
	final public void restart_to_login(){
		clear_activities_stack();
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

	final public User current_user() {
		return AccountManager.current_user();
	}

	// ���ӣ���������
	public void on_go_back() {
	};
	
	
	// ���Դӻ����ȡһ��ͼƬ�ŵ�ָ����view
	final public void load_cached_image(String image_url, ImageView image_view){
		FeedImageCache.load_cached_image(image_url, image_view);
	}
	

}
