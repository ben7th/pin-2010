package com.mindpin.model;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.mindpin.model.base.BaseModel;

public class ContactUser extends BaseModel {
	
	private static Map<String, WeakReference<ContactUser>> contact_user_refs
		= Collections.synchronizedMap(new LinkedHashMap<String, WeakReference<ContactUser>>());
	
	public int user_id;
	public String name;
	public String sign;
	public boolean v2_activate;
	public boolean following;
	public String avatar_url;

	// һ��ÿ��model��������ͷ
	final public static ContactUser NIL_CONTACT_USER = new ContactUser();
	private ContactUser(){
		set_nil();
	}
	
	// ���캯��ֻ�������� json_str �������ĺ��������Ҳ�����
	private ContactUser(String json_str) throws JSONException{		
		JSONObject json = new JSONObject(json_str);
		
		this.user_id     = json.getInt("id");
		this.name        = json.getString("name");
		this.sign        = json.getString("sign");
		this.v2_activate = json.getBoolean("v2_activate");
		this.following   = json.getBoolean("following");
		this.avatar_url  = json.getString("avatar_url");
		
		contact_user_refs.put(json_str, new WeakReference<ContactUser>(this));
	}
	
	// ֻ����build��build_list_by_json
	public static ContactUser build(String json_str) throws JSONException{
		if(json_str == "null"){
			return ContactUser.NIL_CONTACT_USER;
		}
		
		// �ȳ��Դ�MAP�л�ȡ
		if (contact_user_refs.containsKey(json_str)) {
			WeakReference<ContactUser> ref = contact_user_refs.get(json_str);
			if (null != ref) {
				ContactUser contact_user = ref.get();
				if (null != contact_user) {
					return contact_user;
				}
			}
		}
		
		// û�л�ȡ�����ٹ��죬�����ȽϽ�Լ�ڴ��cpu
		return new ContactUser(json_str);
	}

	public static List<ContactUser> build_list_by_json(String json_str) throws JSONException {
		List<ContactUser> list = new ArrayList<ContactUser>();
		JSONArray json_array = new JSONArray(json_str);
		
		for (int i = 0; i < json_array.length(); i++) {
			String contact_user_json_str = json_array.getString(i);	
			list.add(ContactUser.build(contact_user_json_str));
		}
		return list;
	}

}
