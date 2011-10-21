package com.mindpin.database;

import java.util.ArrayList;
import org.json.JSONException;
import org.json.JSONObject;
import com.mindpin.Logic.Global;
import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

public class User {
	public int id;
	public int user_id;
	public String name;
	public String cookies;
	public String info;
	
	public User(int id,int user_id,String name,String cookies,String info){
		this.id = id;
		this.user_id = user_id;
		this.name = name;
		this.cookies = cookies;
		this.info = info;
	}

	public static int get_count(){
		SQLiteDatabase db = get_read_db();
		Cursor cursor = db.query(Constants.TABLE_USERS,new String[]{Constants.KEY_ID}, null, null, null, null, null);
		int count = cursor.getCount();
		db.close();
		return count;
	}
	
	public static User find(int uid){
		SQLiteDatabase db = get_read_db();
		Cursor cursor = db.query(Constants.TABLE_USERS,
				new String[]{
								Constants.KEY_ID,
								Constants.TABLE_USERS__USER_ID,
								Constants.TABLE_USERS__NAME,
								Constants.TABLE_USERS__COOKIES,
								Constants.TABLE_USERS__INFO
							}, 
							Constants.TABLE_USERS__USER_ID + " = "+ uid, null, null, null,null);
		boolean has = cursor.moveToFirst();
		db.close();
		if(has){
			int id = cursor.getInt(0);
			int user_id = cursor.getInt(1);
			String name = cursor.getString(2);
			String cookies = cursor.getString(3);
			String info = cursor.getString(4);
			User fh = new User(id,user_id,name,cookies,info);
			return fh;
		}else{
			return null;
		}
	}
	
	public boolean is_v2_activate(){
		try {
			JSONObject info_json = new JSONObject(info);
			return (Boolean)info_json.get("v2_activate");
		} catch (JSONException e) {
			return false;
		}
	}
	
	public static ArrayList<User> get_users(){
		SQLiteDatabase db = get_read_db();
		Cursor cursor = db.query(Constants.TABLE_USERS,
				new String[]{
								Constants.KEY_ID,
								Constants.TABLE_USERS__USER_ID,
								Constants.TABLE_USERS__NAME,
								Constants.TABLE_USERS__COOKIES,
								Constants.TABLE_USERS__INFO
							}, 
				null, null, null, null,Constants.KEY_ID+ " asc");
		ArrayList<User> fhs = new ArrayList<User>();
		while(cursor.moveToNext()){
			int id = cursor.getInt(0);
			int user_id = cursor.getInt(1);
			String name = cursor.getString(2);
			String cookies = cursor.getString(3);
			String info = cursor.getString(4);
			User fh = new User(id,user_id,name,cookies,info);
			fhs.add(fh);
		}
		db.close();
		return fhs;
	}
	
	private static SQLiteDatabase get_write_db(){
		MindpinDBHelper md = new MindpinDBHelper(Global.application_context, Constants.DATABASE_NAME,
				null, Constants.DATABASE_VERSION);
		return md.getWritableDatabase();
	}
	
	private static SQLiteDatabase get_read_db(){
		MindpinDBHelper md = new MindpinDBHelper(Global.application_context, Constants.DATABASE_NAME,
				null, Constants.DATABASE_VERSION);
		return md.getReadableDatabase();
	}
	
	public static void destroy(int user_id) {
		SQLiteDatabase db = get_write_db();
		db.execSQL("DELETE FROM "+ Constants.TABLE_USERS +" WHERE "+Constants.TABLE_USERS__USER_ID+" = ?", new Object[]{user_id});
		db.close();
	}

	public static void update_info(int user_id, String name,
			String info) {
		SQLiteDatabase db = get_write_db();
		
		ContentValues values = new ContentValues();
		values.put(Constants.TABLE_USERS__NAME,name);
		values.put(Constants.TABLE_USERS__INFO,info);
		db.update(Constants.TABLE_USERS, values,Constants.TABLE_USERS__USER_ID + " = "+ user_id,null);
		db.close();
	}
	
	public static void update(int user_id, String name,
			String cookies,String info) {
		SQLiteDatabase db = get_write_db();
		
		ContentValues values = new ContentValues();
		values.put(Constants.TABLE_USERS__NAME,name);
		values.put(Constants.TABLE_USERS__COOKIES,cookies);
		values.put(Constants.TABLE_USERS__INFO,info);
		db.update(Constants.TABLE_USERS, values,Constants.TABLE_USERS__USER_ID + " = "+ user_id,null);
		db.close();
	}

	public static void insert(int user_id, String name,
			String cookies,String info) {
		SQLiteDatabase db = get_write_db();
		
		ContentValues values = new ContentValues();
		values.put(Constants.TABLE_USERS__USER_ID,user_id);
		values.put(Constants.TABLE_USERS__NAME,name);
		values.put(Constants.TABLE_USERS__COOKIES,cookies);
		values.put(Constants.TABLE_USERS__INFO,info);
		db.insert(Constants.TABLE_USERS,null, values);
		db.close();
	}
}
