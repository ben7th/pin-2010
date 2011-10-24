package com.mindpin.Logic;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.mindpin.base.utils.FileDirs;

public class CompressPhoto {

	public static String get_compress_file_path(String original_file_path){
		int quality_size = MindpinPreferences.get_photo_quality();
		if(quality_size == 0){
			return original_file_path;
		}
		
		BitmapFactory.Options options = new BitmapFactory.Options();
		//  �����ֵ��Ϊtrue��ô��������ʵ�ʵ�bitmap
		//	����������ڴ�ռ������ֻ����һЩ����߽���Ϣ��ͼƬ��С��Ϣ	
        options.inJustDecodeBounds = true;
        //	��ȡ���ͼƬ�Ŀ�͸�
        //	��ʱ����bmΪ��
        BitmapFactory.decodeFile(original_file_path, options); 
        options.inSampleSize = quality_size;
        
        options.inJustDecodeBounds = false;
        Bitmap bitmap = BitmapFactory.decodeFile(original_file_path,options);
        
        File file=new File(FileDirs.MINDPIN_DIR, "upload_tmp.png");
        if(file.exists()){
        	file.delete();
        	file=new File(FileDirs.MINDPIN_DIR, "upload_tmp.png");
        }
        try {
            FileOutputStream out=new FileOutputStream(file);
            if(bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)){
                out.flush();
                out.close();
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
		return file.getPath();
	}
}
