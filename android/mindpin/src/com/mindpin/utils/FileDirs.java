package com.mindpin.utils;

import java.io.File;

import android.os.Environment;

public class FileDirs {

	// ���Ի��һ���ļ��о��������ļ��в����ھʹ������ļ���
    public static File get_or_create_dir(String path){
    	File dir = new File(
			Environment.getExternalStorageDirectory().getPath() + path
		);
		if (!dir.exists()) {
			dir.mkdirs();
		}
		return dir;
    }
    
    public final static File MINDPIN_DIR 	     = get_or_create_dir("/mindpin/");
    public final static File MINDPIN_CAPTURE_DIR = get_or_create_dir("/mindpin/capture/");
	public final static File MINDPIN_CACHE_DIR   = get_or_create_dir("/mindpin/cache");
}
