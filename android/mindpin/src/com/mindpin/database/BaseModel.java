package com.mindpin.database;

import android.database.sqlite.SQLiteDatabase;

import com.mindpin.application.MindpinApplication;

public abstract class BaseModel {
	final private static MindpinDBHelper get_db_helper() {
		return new MindpinDBHelper(MindpinApplication.context,
				Constants.DATABASE_NAME, null, Constants.DATABASE_VERSION);
	}

	final static SQLiteDatabase get_write_db() {
		return get_db_helper().getWritableDatabase();
	}

	final static SQLiteDatabase get_read_db() {
		return get_db_helper().getReadableDatabase();
	}
}