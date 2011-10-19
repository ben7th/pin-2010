package com.mindpin.base.utils;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.Reader;
import java.io.StringWriter;
import java.io.Writer;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

import android.content.Context;
import android.content.res.Resources;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.TypedValue;
import android.widget.Toast;

import com.mindpin.Logic.Global;

public class BaseUtils {
	
	
	public static int get_px_by_dip(Context context,int dip) {
		Resources r = context.getResources();
		return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dip, r.getDisplayMetrics());
	}
	
	public static String date_string(long time){
		SimpleDateFormat sdf = new SimpleDateFormat();
		sdf.applyPattern("yyyy-MM-dd HH:mm:ss");
		return sdf.format(new Date(time));
	}
	
	public static boolean is_wifi_active(Context context) {
		Context acontext = context.getApplicationContext();
		ConnectivityManager connectivity = (ConnectivityManager) acontext
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		if (connectivity != null) {
			NetworkInfo[] info = connectivity.getAllNetworkInfo();
			if (info != null) {
				for (int i = 0; i < info.length; i++) {
					if (info[i].getTypeName().equals("WIFI")
							&& info[i].isConnected()) {
						return true;
					}
				}
			}
		}
		return false;
	}
	
	// [1,2,3,4] -> "1,2,3,4"
	public static String integer_list_to_string(ArrayList<Integer> ids){
		String res = "";
		if(ids !=null){
			for (Integer s : ids){
				if("".equals(res)){
					res = res + s;
				}else{
					res = res + "," + s;
				}
			}
		}
		return res;
	}
	
	// ["1","2","3","4"] -> "1,2,3,4"
	public static String string_list_to_string(ArrayList<String> strs){
		String res="";
		if(strs !=null){
			for (String s : strs){
				if("".equals(res)){
					res = res + s;
				}else{
					res = res + "," + s;
				}
			}
		}
		return res;
	}
	
	public static ArrayList<String> string_to_string_list(String string){
		ArrayList<String> list = new ArrayList<String>();
		String[] arr = string.split(",");
		for (String str : arr) {
			if(!"".equals(str)){
				list.add(str);
			}
		}
		return list;
	}
	
	public static ArrayList<Integer> string_to_integer_list(String string){
		ArrayList<Integer> list = new ArrayList<Integer>();
		String[] arr = string.split(",");
		for (String str : arr) {
			if(!"".equals(str)){
				list.add(Integer.parseInt(str));
			}
		}
		return list;		
	}

	// 把字节流转换成字符串
	public static String convert_stream_to_string(InputStream is) {
		if (is != null) {
			Writer writer = new StringWriter();
	
			char[] buffer = new char[1024];
			try {
				Reader reader = new BufferedReader(new InputStreamReader(is,
						"UTF-8"));
				int n;
				while ((n = reader.read(buffer)) != -1) {
					writer.write(buffer, 0, n);
				}
			} catch (Exception e) {
				return "";
			} finally {
				try {
					is.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			return writer.toString();
		} else {
			return "";
		}
	}
	
    public static byte[] toByteArray(InputStream input) throws IOException {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        copy(input, output);
        return output.toByteArray();
    }
    
    public static int copy(InputStream input, OutputStream output) throws IOException {
        long count = copyLarge(input, output);
        if (count > Integer.MAX_VALUE) {
            return -1;
        }
        return (int) count;
    }
    
    public static long copyLarge(InputStream input, OutputStream output)
            throws IOException {
        byte[] buffer = new byte[1024 * 4];
        long count = 0;
        int n = 0;
        while (-1 != (n = input.read(buffer))) {
            output.write(buffer, 0, n);
            count += n;
        }
        return count;
    }
    
    //判断字符串非空
    public static boolean isStrBlank(String str) {
    	int length;

    	if ((str == null) || ((length = str.length()) == 0)) {
    		return true;
    	}

    	for (int i = 0; i < length; i++) {
    		if (!Character.isWhitespace(str.charAt(i))) {
    			return false;
    		}
    	}
    	return true;
    }
    
    // 快速显示一个toast
    public static void toast(int string_resource_id){
		Toast.makeText(
			Global.application_context, 
			string_resource_id,
			Toast.LENGTH_SHORT
		).show();
    }
}
