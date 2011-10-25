package com.mindpin.database;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.mindpin.Logic.Global;

public abstract class BaseModel {
	final private static MindpinDBHelper get_db_helper() {
		return new MindpinDBHelper(Global.application_context,
				Constants.DATABASE_NAME, null, Constants.DATABASE_VERSION);
	}

	final static SQLiteDatabase get_write_db() {
		return get_db_helper().getWritableDatabase();
	}

	final static SQLiteDatabase get_read_db() {
		return get_db_helper().getReadableDatabase();
	}

	// 尝试根据传入的条件查找一条数据，
	// 如果有数据，则返回cursor
	// 否则返回 null
	final static Cursor query_one(String table, String[] columns, String selection,
			String[] selectionArgs, String groupBy, String having,
			String orderBy) {

		SQLiteDatabase db = get_read_db();
		
		try {
			Cursor cursor = db.query(table, columns, selection, selectionArgs,
					groupBy, having, orderBy);
			boolean has = cursor.moveToFirst();
			return has ? cursor : null;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		} finally {
			db.close();
		}
	}
}