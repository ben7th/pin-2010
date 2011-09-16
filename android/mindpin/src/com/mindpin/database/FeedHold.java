package com.mindpin.database;

import java.util.ArrayList;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

public class FeedHold {
	public int id;
	public String title;
	public String content;
	public String image_paths;
	public String select_collection_ids;

	public FeedHold(String title, String content, String image_paths,
			String select_collection_ids) {
		this.title = title;
		this.content = content;
		this.image_paths = image_paths;
		this.select_collection_ids = select_collection_ids;  
	}
	
	public long insert_to_db(Context context){
		SQLiteDatabase db = get_write_db(context);
		
		ContentValues values = new ContentValues();
		values.put(Constants.TABLE_FEED_HOLDS__TITLE,title);
		values.put(Constants.TABLE_FEED_HOLDS__CONTENT,content);
		values.put(Constants.TABLE_FEED_HOLDS__IMAGE_PATHS,image_paths);
		values.put(Constants.TABLE_FEED_HOLDS__SELECT_COLLECTION_IDS,select_collection_ids);
		
		long res = db.insert(Constants.TABLE_FEED_HOLDS,null, values);
		db.close();
		return res;
	}
	
	public static int get_count(Context context){
		SQLiteDatabase db = get_read_db(context);
		Cursor cursor = db.query(Constants.TABLE_FEED_HOLDS,new String[]{Constants.KEY_ID}, null, null, null, null, null);
		int count = cursor.getCount();
		db.close();
		return count;
	}
	
	public static ArrayList<FeedHold> get_feed_holds(Context context){
		SQLiteDatabase db = get_read_db(context);
		Cursor cursor = db.query(Constants.TABLE_FEED_HOLDS,
				new String[]{
								Constants.KEY_ID,
								Constants.TABLE_FEED_HOLDS__TITLE,
								Constants.TABLE_FEED_HOLDS__CONTENT,
								Constants.TABLE_FEED_HOLDS__IMAGE_PATHS,
								Constants.TABLE_FEED_HOLDS__SELECT_COLLECTION_IDS
							}, 
				null, null, null, null,Constants.KEY_ID+ " asc");
		ArrayList<FeedHold> fhs = new ArrayList<FeedHold>();
		while(cursor.moveToNext()){
			String title = cursor.getString(1);
			String content = cursor.getString(2);
			String image_paths = cursor.getString(3);
			String select_collection_ids = cursor.getString(4);
			FeedHold fh = new FeedHold(title, content, image_paths, select_collection_ids);
			fh.id = cursor.getInt(0);
			fhs.add(fh);
		}
		db.close();
		return fhs;
	}
	
	private static SQLiteDatabase get_write_db(Context context){
		MindpinDBHelper md = new MindpinDBHelper(context, Constants.DATABASE_NAME,
				null, Constants.DATABASE_VERSION);
		return md.getWritableDatabase();
	}
	
	private static SQLiteDatabase get_read_db(Context context){
		MindpinDBHelper md = new MindpinDBHelper(context, Constants.DATABASE_NAME,
				null, Constants.DATABASE_VERSION);
		return md.getReadableDatabase();
	}
	
	public static void destroy_all(Context context){
		SQLiteDatabase db = get_write_db(context);
		db.execSQL("DELETE FROM "+ Constants.TABLE_FEED_HOLDS);
		db.close();
	}

	public static void destroy(Context context,int id) {
		SQLiteDatabase db = get_write_db(context);
		db.execSQL("DELETE FROM "+ Constants.TABLE_FEED_HOLDS +" WHERE "+Constants.KEY_ID+" = ?", new Object[]{id});
		db.close();
	}
}
