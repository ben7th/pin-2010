package com.mindpin.Logic;

import java.util.List;

import org.apache.http.client.CookieStore;
import org.apache.http.cookie.Cookie;
import org.apache.http.impl.client.BasicCookieStore;
import org.apache.http.impl.cookie.BasicClientCookie;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

import com.mindpin.base.utils.BaseUtils;
import com.mindpin.database.User;

public class AccountManager {
	final private static String PREFERENCES_NAME = "Mindpin";
	final private static SharedPreferences SHARED_PREFERENCES = Global.application_context
			.getSharedPreferences(PREFERENCES_NAME, Activity.MODE_PRIVATE);

	final private static String PREFERENCES_KEY_CURRENT_USER_ID = "current_user_id";
	final private static String PREFERENCES_KEY_LAST_SYN_TIME = "last_syn_time";

	public static void switch_account(User user) {
		Editor pre_edit = SHARED_PREFERENCES.edit();
		pre_edit.putInt(PREFERENCES_KEY_CURRENT_USER_ID, user.user_id);
		pre_edit.commit();
	}

	public static void login(List<Cookie> cookies, String info)
			throws Exception {
		User user = new User(cookies, info);
		
		if (user.save()) {
			switch_account(user);
		} else {
			throw new AuthenticateException();
		}
	}

	public static long last_syn_time() {
		long time = SHARED_PREFERENCES.getLong(PREFERENCES_KEY_LAST_SYN_TIME, 0);
		if (time == 0) {
			touch_last_syn_time();
			return last_syn_time();
		} else {
			return time;
		}
	}

	public static void touch_last_syn_time() {
		Editor pre_edit = SHARED_PREFERENCES.edit();
		long time = System.currentTimeMillis();
		pre_edit.putLong(PREFERENCES_KEY_LAST_SYN_TIME, time);
		pre_edit.commit();
	}

	public static CookieStore get_cookie_store() {
		BasicCookieStore cookie_store = new BasicCookieStore();
		String cookies_string = current_user().cookies;
		try {
			if (!BaseUtils.is_str_blank(cookies_string)) {
				JSONArray json_arr = new JSONArray(cookies_string);
				for (int i = 0; i < json_arr.length(); i++) {
					JSONObject json = (JSONObject) json_arr.get(i);
					String name = (String) json.get("name");
					String value = (String) json.get("value");
					String domain = (String) json.get("domain");
					String path = (String) json.get("path");
					BasicClientCookie cookie = new BasicClientCookie(name, value);
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

	public static User current_user() {
		int user_id = SHARED_PREFERENCES.getInt(
				PREFERENCES_KEY_CURRENT_USER_ID, 0);
		return User.find(user_id);
	}

	public static boolean is_logged_in() {
		return !current_user().is_nil();
	}

	public static class AuthenticateException extends Exception {
		private static final long serialVersionUID = 8741487079704426464L;
	}
}
