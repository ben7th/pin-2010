package com.mindpin.application;

import android.app.Application;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

public class MindpinApplication extends Application {

	public static Context context;
	public static LayoutInflater mInflater;

	public static View inflate(int resource, ViewGroup root, boolean attachToRoot){
		return mInflater.inflate(resource, root, attachToRoot);
	}
	
	@Override
	public void onCreate() {
		context = getApplicationContext();

		mInflater = (LayoutInflater) context
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

		super.onCreate();
	}
}
