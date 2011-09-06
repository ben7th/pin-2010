package com.mindpin.Logic;

import java.io.IOException;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

public class AccountManager {
	public static final String PREFERENCES_NAME = "Mindpin";
	
	public static String get_email(Context context) {
		SharedPreferences pre = context.getSharedPreferences(PREFERENCES_NAME,
				Activity.MODE_PRIVATE);
		return pre.getString("email", "");
	}

	public static String get_password(Context context) {
		SharedPreferences pre = context.getSharedPreferences(PREFERENCES_NAME,
				Activity.MODE_PRIVATE);
		return pre.getString("password", "");
	}
	
	public static void save_user_info(Context context,String email, String password) {
		SharedPreferences pre = context.getSharedPreferences(PREFERENCES_NAME,
				Activity.MODE_PRIVATE);
		Editor pre_edit = pre.edit();
		pre_edit.putString("email", email);
		pre_edit.putString("password", password);
		pre_edit.commit();
	}
	
	public static void remove_user_info(Context context) {
		SharedPreferences pre = context.getSharedPreferences(
				AccountManager.PREFERENCES_NAME, Activity.MODE_PRIVATE);
		Editor pre_edit = pre.edit();
		pre_edit.remove("email");
		pre_edit.remove("password");
		pre_edit.commit();
	}
	
	public static boolean user_authenticate(String email, String password) throws IOException {
		boolean auth = false;
		auth = Http.user_authenticate(email, password);
		return auth;
	}
}
