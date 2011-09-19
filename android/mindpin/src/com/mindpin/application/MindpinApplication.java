package com.mindpin.application;

import com.mindpin.Logic.Global;

import android.app.Application;

public class MindpinApplication extends Application{

	@Override
	public void onCreate() {
		Global.application_context = getApplicationContext();
		super.onCreate();
	}
	
}
