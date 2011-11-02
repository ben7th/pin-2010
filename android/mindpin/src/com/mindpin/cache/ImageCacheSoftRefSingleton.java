package com.mindpin.cache;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.lang.ref.SoftReference;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.widget.ImageView;

public class ImageCacheSoftRefSingleton {
	private static ImageCacheSoftRefSingleton instance = new ImageCacheSoftRefSingleton();
	
	private HashMap<String, SoftReference<ImageView>> waiting_image_view_hashmap;
	private Map<File, SoftReference<Bitmap>> used_bitmap_list;
	
	private ImageCacheSoftRefSingleton(){
		waiting_image_view_hashmap = new HashMap<String, SoftReference<ImageView>>();
		used_bitmap_list = Collections.synchronizedMap(new LinkedHashMap<File, SoftReference<Bitmap>>());
	}
	
	// ����ȴ�����hashmap�����Ҹ�image_view����tagֵ�����ڵ��˼���ʱ�ȶԣ��ж��Ƿ��б�Ҫ����bitmap
	public static void put_in_waiting_map(String image_url, ImageView image_view){
		image_view.setTag(image_url);
		instance.waiting_image_view_hashmap.put(image_url, new SoftReference<ImageView>(image_view));
	}
	
	// ���Դӵȴ�����hashmap��ȡ�� image_view�����ж��������Ƿ���Ҫ������bitmap
	// (���� adapter ��������õ���Ϊ�����ܴ�ʱ��tag�м�¼�� url �Ѿ������˱仯)
	// ���view�Ѿ������ջ�����������ԭ���ٿɼ��أ����� null
	final static ImageView get_restored_image_view(String image_url){
		if (instance.waiting_image_view_hashmap.containsKey(image_url)) {

			SoftReference<ImageView> soft_ref = instance.waiting_image_view_hashmap.get(image_url);

			if (null == soft_ref) {
				return null;
			}

			ImageView image_view = soft_ref.get();
			soft_ref.clear(); // �����ͷ�

			if (null != image_view && !image_url.equals(image_view.getTag())) {
				return null;
			}

			return image_view;
		}

		return null;
	}
	
	// ���һ���ļ�Ϊ bitmap ������ image_view
	// ���ҳ���ϲ�����̫��� image_view �� bitmap �ͻᵼ���ڴ����
	// �����Ҫ�ֶ��������ǵ��ڴ��ͷ�
	final static void set_bitmap_to_imageview(File cache_file, ImageView image_view){
		Bitmap img_bitmap;
		try {
			if(null == image_view) return;
			img_bitmap = get_bitmap_from_file(cache_file);
			
			image_view.setImageBitmap(img_bitmap);
			
			
		} catch (Exception e) {
			e.printStackTrace();
		} finally{
			img_bitmap = null;
		}
	}
	
	final static private Bitmap get_bitmap_from_file(File cache_file){
		Bitmap img_bitmap;
		Map<File, SoftReference<Bitmap>> used_bitmap_list = instance.used_bitmap_list;
		
		// �ȳ��Դ������л�ȡ
		if (used_bitmap_list.containsKey(cache_file)) {
			SoftReference<Bitmap> ref = used_bitmap_list.get(cache_file);
			if (null != ref) {
				img_bitmap = ref.get();
				if (null != img_bitmap) {
					return img_bitmap;
				}
			}
		}
		
		try {
			FileInputStream stream = new FileInputStream(cache_file);
			img_bitmap = BitmapFactory.decodeStream(stream);
			
			if(null == img_bitmap){
				cache_file.delete();
			}
			
			clear_used_bitmap_list();
			used_bitmap_list.put(cache_file, new SoftReference<Bitmap>(img_bitmap));
			
			return img_bitmap;
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return null;
		} catch (OutOfMemoryError e){
			e.printStackTrace();
			System.gc();
	        return null;
		}
	}
	
	final static private void clear_used_bitmap_list(){
		Map<File, SoftReference<Bitmap>> used_bitmap_list = instance.used_bitmap_list;
		
		int size = used_bitmap_list.size();
		if(size > 100){
			System.gc();
			Iterator<File> it = used_bitmap_list.keySet().iterator();
			used_bitmap_list.remove(it.next());			
		}
	}
}
