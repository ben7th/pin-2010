package com.mindpin.Logic;

import com.mindpin.R;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

public class MindpinPreferences {

	public static int get_photo_quality(){
		SharedPreferences a = PreferenceManager.getDefaultSharedPreferences(Global.application_context);
		String key = Global.application_context.getResources().getString(R.string.upload_photo_quality);
		String size = a.getString(key, "0");
		return Integer.parseInt(size);
	}
}
