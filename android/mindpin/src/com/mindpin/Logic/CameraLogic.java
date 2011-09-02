package com.mindpin.Logic;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;

public class CameraLogic {
	public final static int REQUEST_CAPTURE = 0;
	public static File image_capture_temp_path;
	public final static String HAS_IMAGE_CAPTURE = "has_image_capture";
	
	// 调用 系统的照相机
	public static void call_sysotem_camera(Activity a) {
		Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
		File capture_dir  = CameraLogic.mindpin_capture_path();
		String name = CameraLogic.capture_name_by_time();
		image_capture_temp_path = new File(capture_dir,name);
		Uri uri = Uri.fromFile(image_capture_temp_path);
		intent.putExtra(MediaStore.EXTRA_OUTPUT, uri);
		a.startActivityForResult(intent, CameraLogic.REQUEST_CAPTURE);
	}

	// 得到存放 mindpin 相片的文件夹句柄
	public static File mindpin_capture_path(){
		File capture_dir = new File(Environment.getExternalStorageDirectory()
				.getPath() + "/mindpin/capture/");
		if (!capture_dir.exists()) {
			capture_dir.mkdirs();
		}
		return capture_dir;
	}

	// 根据当前时间得到一个文件名
	public static String capture_name_by_time(){
		SimpleDateFormat sdf = new SimpleDateFormat();
		sdf.applyPattern("yyyyMMdd_HHmmss");
		String str = sdf.format(new Date());
		return "IMG_" + str + ".jpg";
	}
}
