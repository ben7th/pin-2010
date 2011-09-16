package com.mindpin.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabase.CursorFactory;
import android.database.sqlite.SQLiteOpenHelper;

public class MindpinDBHelper extends SQLiteOpenHelper{
	private static final String create_table_feed_holds = "create table " +
			Constants.TABLE_FEED_HOLDS+" (" +
			Constants.KEY_ID+" integer primary key autoincrement, "+
			Constants.TABLE_FEED_HOLDS__TITLE+" text not null, "+
			Constants.TABLE_FEED_HOLDS__CONTENT+" text not null, "+
			Constants.TABLE_FEED_HOLDS__IMAGE_PATHS+" text not null, "+
			Constants.TABLE_FEED_HOLDS__SELECT_COLLECTION_IDS+" text not null);";
	

	public MindpinDBHelper(Context context, String name, CursorFactory factory,
			int version) {
		super(context, name, factory, version);
	}

	@Override
	public void onCreate(SQLiteDatabase db) {
		db.execSQL(create_table_feed_holds);
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		db.execSQL("drop table if exists "+Constants.TABLE_FEED_HOLDS);
		onCreate(db);
	}
}
