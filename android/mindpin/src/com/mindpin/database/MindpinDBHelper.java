package com.mindpin.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabase.CursorFactory;
import android.database.sqlite.SQLiteOpenHelper;

public class MindpinDBHelper extends SQLiteOpenHelper{
	private static final String create_table_feed_drafts = "create table " +
			Constants.TABLE_FEED_DRAFTS+" (" +
			Constants.KEY_ID+" integer primary key autoincrement, "+
			Constants.TABLE_FEED_DRAFTS__TITLE+" text not null, "+
			Constants.TABLE_FEED_DRAFTS__CONTENT+" text not null, "+
			Constants.TABLE_FEED_DRAFTS__IMAGE_PATHS+" text not null, "+
			Constants.TABLE_FEED_DRAFTS__SELECT_COLLECTION_IDS+" text not null, " +
			Constants.TABLE_FEED_DRAFTS__SEND_TSINA+" integer not null, " +
			Constants.TABLE_FEED_DRAFTS__TIME+" long not null);";
	

	public MindpinDBHelper(Context context, String name, CursorFactory factory,
			int version) {
		super(context, name, factory, version);
	}

	@Override
	public void onCreate(SQLiteDatabase db) {
		db.execSQL(create_table_feed_drafts);
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		db.execSQL("drop table if exists "+Constants.TABLE_FEED_DRAFTS);
		onCreate(db);
	}
}
