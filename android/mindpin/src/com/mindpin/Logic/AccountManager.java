package com.mindpin.Logic;

import java.util.List;
import org.apache.http.client.CookieStore;
import org.apache.http.cookie.Cookie;
import org.apache.http.impl.client.BasicCookieStore;
import org.apache.http.impl.cookie.BasicClientCookie;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.mindpin.base.utils.BaseUtils;
import com.mindpin.cache.CollectionsCache;
import com.mindpin.database.FeedDraft;
import com.mindpin.database.User;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.graphics.Bitmap;

public class AccountManager {
	public static final String PREFERENCES_NAME = "Mindpin";
	
	public static void switch_account(int user_id){
		SharedPreferences pre = Global.application_context
				.getSharedPreferences(AccountManager.PREFERENCES_NAME,
						Activity.MODE_PRIVATE);
		Editor pre_edit = pre.edit();
		pre_edit.putString("current_user",user_id+"");
		pre_edit.commit();
	}

	public static void login(List<Cookie> cookies, String info) throws Exception {
		int user_id = Account.save( cookies, info);
		switch_account(user_id);
	}
	
	public static void remove(int user_id){
		SharedPreferences pre = Global.application_context
				.getSharedPreferences(AccountManager.PREFERENCES_NAME,
						Activity.MODE_PRIVATE);
		Editor pre_edit = pre.edit();
		pre_edit.remove("current_user");
		pre_edit.remove("last_syn_time");
		pre_edit.commit();
		
		Account.delete(user_id);
		CollectionsCache.delete(user_id);
		FeedDraft.destroy_all(user_id);
	}
	
	public static int current_user_id(){
		SharedPreferences pre = Global.application_context
				.getSharedPreferences(AccountManager.PREFERENCES_NAME,
						Activity.MODE_PRIVATE);
		String id = pre.getString("current_user","0");
		return Integer.parseInt(id);
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
	
	public static CookieStore get_cookie_store(){
		BasicCookieStore cookie_store = new BasicCookieStore();
		String cookies_string = get_current_user_cookies_string();
		try {
			if(!BaseUtils.isStrBlank(cookies_string)){
				JSONArray json_arr = new JSONArray(cookies_string);
				for (int i = 0; i < json_arr.length(); i++) {
					JSONObject json = (JSONObject)json_arr.get(i);
					String name = (String)json.get("name");
					String value = (String)json.get("value");
					String domain = (String)json.get("domain");
					String path = (String)json.get("path");
					BasicClientCookie cookie = new BasicClientCookie(name,value);
					cookie.setDomain(domain);
					cookie.setPath(path);
					cookie_store.addCookie(cookie);
				}
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		return cookie_store;
	}
	
	public static boolean is_logged_in() {
		int count = User.get_count();
		if(count != 0 && current_user_id() == 0){
			switch_account(User.get_users().get(0).user_id);
		}
		return (0 != count);
	}
	
	private static String get_current_user_cookies_string(){
		int user_id = current_user_id();
		if(user_id == 0){
			return null;
		}else{
			return User.find(user_id).cookies;
		}
	}
	
	public static class AuthenticateException extends Exception{
		private static final long serialVersionUID = 8741487079704426464L;
	}

	public static Bitmap get_current_user_avatar_bitmap() {
		int user_id = current_user_id();
		if(user_id == 0){
			return null;
		}else{
			return Account.get_avatar_bitmap(user_id);
		}
	}

	public static String get_current_user_name() {
		int user_id = current_user_id();
		if(user_id == 0){
			return null;
		}else{
			return User.find(user_id).name;
		}
	}

	public static boolean current_user_is_activation_user() {
		int user_id = current_user_id();
		if(user_id == 0){
			return false;
		}else{
			return User.find(user_id).is_v2_activate();
		}
	}
}
