package com.mindpin.Logic;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


import com.mindpin.utils.BaseUtils;

public class Http { 
	private static final String SITE = "http://dev.www.mindpin.com";
	private static DefaultHttpClient httpclient = new DefaultHttpClient();

	public static boolean user_authenticate(String email, String password)
			throws IOException {
		HttpPost httpost = new HttpPost(SITE + "/session");
		httpost.setHeader("User-Agent", "android");

		List<NameValuePair> nvps = new ArrayList<NameValuePair>();
		nvps.add(new BasicNameValuePair("email", email));
		nvps.add(new BasicNameValuePair("password", password));
		httpost.setEntity(new UrlEncodedFormEntity(nvps, HTTP.UTF_8));

		HttpResponse response = httpclient.execute(httpost);
		response.getEntity().getContent().close();
		String res = response.getStatusLine().toString();
		if ("HTTP/1.1 200 OK".equals(res)) {
			return true;
		} else {
			return false;
		}
	}

	public static List<HashMap<String, Object>> get_feed_timeline() throws IOException{
	    HttpGet httpget = new HttpGet(SITE);
	    httpget.setHeader("User-Agent", "android");
        HttpResponse response = httpclient.execute(httpget);
        HttpEntity entity = response.getEntity();
        if (entity == null) {
        	return null;
        }
        List<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
        try {
			String json_str = BaseUtils.convert_stream_to_string(entity.getContent());
			JSONArray feed_json_arr = new JSONArray(json_str);
			for(int i=0;i<feed_json_arr.length();i++){
				JSONObject feed_json = feed_json_arr.getJSONObject(i);
				JSONObject feed_attrs = (JSONObject)feed_json.get("feed");
				HashMap<String,Object> map = new HashMap<String,Object>();
				map.put("id", feed_attrs.getInt("id"));
				map.put("content",feed_attrs.getString("content"));
				list.add(map);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
        return list;
	}

	public static boolean send_feed(String title, String content,
			ArrayList<String> images)  {
		try {
			HttpPost httpost = new HttpPost(SITE + "/feeds");
			httpost.setHeader("User-Agent", "android");
			MultipartEntity me = new MultipartEntity();
			
			StringBody content_body = new StringBody(title, Charset.forName(HTTP.UTF_8));
			StringBody detail_body = new StringBody(content,Charset.forName(HTTP.UTF_8));
			me.addPart("content",content_body);
			me.addPart("detail",detail_body);
			
			for (int i = 0; i < images.size(); i++) {
				String image = images.get(i);
				File file = new File(image);
				FileBody bin = new FileBody(file,"image/jpeg");
				me.addPart("photos[]",bin);
			}
			httpost.setEntity(me);
			HttpResponse response = httpclient.execute(httpost);
			response.getEntity().getContent().close();
			String res = response.getStatusLine().toString();
			if ("HTTP/1.1 200 OK".equals(res)) {
				return true;
			} else {
				return false;
			}
		} catch (ClientProtocolException e) {
			e.printStackTrace();
			return false;
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
	}
}
