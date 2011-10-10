package com.mindpin.Logic;
import java.util.List;

import org.apache.http.client.CookieStore;
import org.apache.http.cookie.Cookie;
import org.apache.http.impl.client.BasicCookieStore;
import org.apache.http.impl.cookie.BasicClientCookie;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.mindpin.cache.AccountInfoCache;
import com.mindpin.cache.CollectionsCache;
import com.mindpin.database.FeedDraft;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

public class AccountManager {
	public static final String PREFERENCES_NAME = "Mindpin";

	public static void login(List<Cookie> cookies, String info) {
		try {
			AccountInfoCache.save(info);
			SharedPreferences pre = Global.application_context
					.getSharedPreferences(AccountManager.PREFERENCES_NAME,
							Activity.MODE_PRIVATE);
			Editor pre_edit = pre.edit();
			JSONArray json_arr = new JSONArray();
			for (Cookie cookie : cookies) {
				JSONObject json = new JSONObject();
				json.put("name", cookie.getName());
				json.put("value", cookie.getValue());
				json.put("domain", cookie.getDomain());
				json.put("path", cookie.getPath());
				json_arr.put(json);
			}
			pre_edit.putString("cookies", json_arr.toString());
			pre_edit.commit();
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}
	
	public static void logout(){
		SharedPreferences pre = Global.application_context
				.getSharedPreferences(AccountManager.PREFERENCES_NAME,
						Activity.MODE_PRIVATE);
		Editor pre_edit = pre.edit();
		pre_edit.remove("cookies");
		pre_edit.remove("last_syn_time");
		pre_edit.commit();

		AccountInfoCache.destroy();
		CollectionsCache.destroy();
		FeedDraft.destroy_all(Global.application_context);
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
		String cookies_string = get_cookies_string();
		try {
			if(!"".equals(cookies_string)){
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
		String cookies = get_cookies_string();
		return !"".equals(cookies);
	}
	
	private static String get_cookies_string(){
		SharedPreferences pre = Global.application_context.getSharedPreferences(
				AccountManager.PREFERENCES_NAME, Activity.MODE_PRIVATE);
		return pre.getString("cookies", "");
	}
	
	public static class AuthenticateException extends Exception{
		private static final long serialVersionUID = 8741487079704426464L;
	}
}
