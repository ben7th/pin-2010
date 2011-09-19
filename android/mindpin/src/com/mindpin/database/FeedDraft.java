package com.mindpin.database;

import java.util.ArrayList;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

public class FeedDraft {
	public int id;
	public String title;
	public String content;
	public String image_paths;
	public String select_collection_ids;
	public long time;

	public FeedDraft(String title, String content, String image_paths,
			String select_collection_ids,long time) {
		this.title = title;
		this.content = content;
		this.image_paths = image_paths;
		this.select_collection_ids = select_collection_ids;  
	}
	
	public static int get_count(Context context){
		SQLiteDatabase db = get_read_db(context);
		Cursor cursor = db.query(Constants.TABLE_FEED_DRAFTS,new String[]{Constants.KEY_ID}, null, null, null, null, null);
		int count = cursor.getCount();
		db.close();
		return count;
	}
	
	public static ArrayList<FeedDraft> get_feed_drafts(Context context){
		SQLiteDatabase db = get_read_db(context);
		Cursor cursor = db.query(Constants.TABLE_FEED_DRAFTS,
				new String[]{
								Constants.KEY_ID,
								Constants.TABLE_FEED_DRAFTS__TITLE,
								Constants.TABLE_FEED_DRAFTS__CONTENT,
								Constants.TABLE_FEED_DRAFTS__IMAGE_PATHS,
								Constants.TABLE_FEED_DRAFTS__SELECT_COLLECTION_IDS,
								Constants.TABLE_FEED_DRAFTS__TIME
							}, 
				null, null, null, null,Constants.KEY_ID+ " asc");
		ArrayList<FeedDraft> fhs = new ArrayList<FeedDraft>();
		while(cursor.moveToNext()){
			String title = cursor.getString(1);
			String content = cursor.getString(2);
			String image_paths = cursor.getString(3);
			String select_collection_ids = cursor.getString(4);
			long time = cursor.getLong(5);
			FeedDraft fh = new FeedDraft(title, content, image_paths, select_collection_ids,time);
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
		db.execSQL("DELETE FROM "+ Constants.TABLE_FEED_DRAFTS);
		db.close();
	}

	public static void destroy(Context context,int id) {
		SQLiteDatabase db = get_write_db(context);
		db.execSQL("DELETE FROM "+ Constants.TABLE_FEED_DRAFTS +" WHERE "+Constants.KEY_ID+" = ?", new Object[]{id});
		db.close();
	}

	public static void update(Context context, int feed_draft_id, String feed_title,
			String feed_content, String images_str,
			String select_collection_ids_str) {
		SQLiteDatabase db = get_write_db(context);
		
		ContentValues values = new ContentValues();
		values.put(Constants.TABLE_FEED_DRAFTS__TITLE,feed_title);
		values.put(Constants.TABLE_FEED_DRAFTS__CONTENT,feed_content);
		values.put(Constants.TABLE_FEED_DRAFTS__IMAGE_PATHS,images_str);
		values.put(Constants.TABLE_FEED_DRAFTS__SELECT_COLLECTION_IDS,select_collection_ids_str);
		values.put(Constants.TABLE_FEED_DRAFTS__TIME,System.currentTimeMillis());
		
		db.update(Constants.TABLE_FEED_DRAFTS, values,Constants.KEY_ID + " = "+ feed_draft_id,null);
		db.close();
	}

	public static void insert(Context context, String title, String content,
			String images_str, String select_collection_ids_str) {
		SQLiteDatabase db = get_write_db(context);
		
		ContentValues values = new ContentValues();
		values.put(Constants.TABLE_FEED_DRAFTS__TITLE,title);
		values.put(Constants.TABLE_FEED_DRAFTS__CONTENT,content);
		values.put(Constants.TABLE_FEED_DRAFTS__IMAGE_PATHS,images_str);
		values.put(Constants.TABLE_FEED_DRAFTS__SELECT_COLLECTION_IDS,select_collection_ids_str);
		values.put(Constants.TABLE_FEED_DRAFTS__TIME,System.currentTimeMillis());
		
		db.insert(Constants.TABLE_FEED_DRAFTS,null, values);
		db.close();
	}
}
