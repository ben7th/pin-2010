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
		//System.out.println("处理前：activities堆栈包含"+ activities_stack.size() +"个实例");
		
		// 先遍历查找相同类型的 activitiy，如果存在，就清除并关闭两个activity之间的所有实例
		// 先查找类型相同的实例的下标
		int index = -1;
		int size = activities_stack.size();
		for (int i = 0; i < size; i++) {
			MindpinBaseActivity activity = activities_stack.get(i);
			if (cls == activity.getClass()) {
				index = i;
				break;
			}
		}
		
		// 如果找到，清除之
		if(index > -1){
			int pops_count = size - index;
			for (int i = 0; i < pops_count; i++) {
				MindpinBaseActivity item = activities_stack.pop();
				item.finish();
			}
		}
		activities_stack.push(this);
		
		//System.out.println("处理后：activities堆栈包含"+ activities_stack.size() +"个实例");
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		//System.out.println(this.getClass().toString() + "destroy");
		//System.out.println("处理前：activities堆栈包含"+ activities_stack.size() +"个实例");
		activities_stack.remove(this);
		//System.out.println("处理前：activities堆栈包含"+ activities_stack.size() +"个实例");
		unregisterReceiver(FeedImageCache.syn_image_broadcast_receiver);
	}
	
	// 关闭所有堆栈中的activity
	final private void clear_activities_stack(){
		int size = activities_stack.size();
		for(int i=0;i<size;i++){
			MindpinBaseActivity activity = activities_stack.pop();
			activity.finish();
		}
	}
	
	// 关闭所有activity，并重新打开login
	final public void restart_to_login(){
		clear_activities_stack();
		open_activity(LoginActivity.class);
	}

	// 绑定在顶栏 go_back 按钮上的事件处理
	final public void go_back(View view) {
		on_go_back();
		this.finish();
	}

	// 打开一个新的activity，此方法用来简化调用
	final public void open_activity(Class<?> cls) {
		startActivity(new Intent(getApplicationContext(), cls));
	}

	final public boolean is_logged_in() {
		return AccountManager.is_logged_in();
	}

	final public User current_user() {
		return AccountManager.current_user();
	}

	// 钩子，自行重载
	public void on_go_back() {
	};
	
	
	// 尝试从缓存获取一个图片放到指定的view
	final public void load_cached_image(String image_url, ImageView image_view){
		FeedImageCache.load_cached_image(image_url, image_view);
	}
	

}
