package com.mindpin.model;

import org.json.JSONException;
import org.json.JSONObject;

import com.mindpin.model.base.BaseModel;

public class AccountUser extends BaseModel {	
	public String cookies;
	public String info;
	
	public int user_id;
	public String name;
	public String sign;
	public boolean v2_activate;
	public String avatar_url;
	
	// ��һ�������userʵ������ʾһ����user
	// �� is_nil() �������ж��Ƿ��user
	// ������ null == user ���ж�
	final public static AccountUser NIL_ACCOUNT_USER = new AccountUser();
	private AccountUser(){
		set_nil();
	}
	
	public AccountUser(String cookies, String info) throws JSONException{
		this.cookies = cookies;
		this.info = info;
		
		JSONObject json = new JSONObject(info);
		
		this.user_id     = json.getInt("id");
		this.name        = json.getString("name");
		this.sign        = json.getString("sign");
		this.v2_activate = json.getBoolean("v2_activate");
		this.avatar_url  = json.getString("avatar_url");
	}
}
