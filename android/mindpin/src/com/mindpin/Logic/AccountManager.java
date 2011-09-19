package com.mindpin.Logic;

import com.mindpin.Logic.Http.IntentException;
import com.mindpin.cache.AccountInfoCache;
import com.mindpin.cache.CollectionsCache;
import com.mindpin.database.FeedDraft;
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
	
	public static boolean has_user_info(Context context){
		String email = AccountManager.get_email(context);
		String password = AccountManager.get_password(context);
		return (!"".equals(email) && !"".equals(password));
	}
	
	public static void save_user_info(Context context,String email, String password) {
		SharedPreferences pre = context.getSharedPreferences(PREFERENCES_NAME,
				Activity.MODE_PRIVATE);
		Editor pre_edit = pre.edit();
		pre_edit.putString("email", email);
		pre_edit.putString("password", password);
		pre_edit.commit();
	}
	
	public static void logout(Context context){
		SharedPreferences pre = context.getSharedPreferences(
				AccountManager.PREFERENCES_NAME, Activity.MODE_PRIVATE);
		Editor pre_edit = pre.edit();
		pre_edit.remove("email");
		pre_edit.remove("password");
		pre_edit.remove("last_syn_time");
		pre_edit.commit();
		
		AccountInfoCache.destroy();
		CollectionsCache.destroy();
		FeedDraft.destroy_all(context);
		Http.set_logout();
	}
	
	public static boolean user_authenticate(String email, String password) throws IntentException {
		return Http.user_authenticate(email, password);
	}

	public static long last_syn_time(Context context) {
		SharedPreferences pre = context.getSharedPreferences(
				AccountManager.PREFERENCES_NAME, Activity.MODE_PRIVATE);
		long time = pre.getLong("last_syn_time",0);
		if(time == 0){
			touch_last_syn_time(context);
			return last_syn_time(context);
		}else{
			return time;
		}
	}

	public static void touch_last_syn_time(Context context) {
		SharedPreferences pre = context.getSharedPreferences(
				AccountManager.PREFERENCES_NAME, Activity.MODE_PRIVATE);
		Editor pre_edit = pre.edit();
		long time = System.currentTimeMillis();
		pre_edit.putLong("last_syn_time", time);
		pre_edit.commit();
	}
	
	public static class AuthenticateException extends Exception{
		private static final long serialVersionUID = 8741487079704426464L;
	}
}
