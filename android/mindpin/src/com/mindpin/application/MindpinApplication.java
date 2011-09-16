package com.mindpin.application;

import android.app.Application;
import android.os.Handler;

public class MindpinApplication extends Application{
	public Handler send_feed_hold_handler;

	@Override
	public void onCreate() {
		super.onCreate();
	}
	
}
