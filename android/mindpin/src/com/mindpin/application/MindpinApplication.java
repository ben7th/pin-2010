package com.mindpin.application;

import com.mindpin.Logic.Global;
import com.mindpin.activity.base.MainActivity;

import android.app.Application;

public class MindpinApplication extends Application{
	// ±£´æ main_activity µÄÊµÀý
	private MainActivity main_activity;
	@Override
	public void onCreate() {
		Global.application_context = getApplicationContext();
		super.onCreate();
	}
	
	public MainActivity get_main_activity(){
		return this.main_activity;
	}
	
	public void set_main_activity(MainActivity main_activity){
		this.main_activity = main_activity;
	}
	
	
}
