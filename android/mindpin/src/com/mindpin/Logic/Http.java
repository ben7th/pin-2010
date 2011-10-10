package com.mindpin.Logic;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import org.apache.commons.io.IOUtils;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.mindpin.Logic.AccountManager.AuthenticateException;
import com.mindpin.cache.AccountInfoCache;
import com.mindpin.cache.CollectionsCache;
import com.mindpin.utils.BaseUtils;

public class Http {
	private static final String SITE = "http://dev.www.mindpin.com";
	private static DefaultHttpClient httpclient = new DefaultHttpClient();
	
	public static boolean user_authenticate(String email, String password) throws IntentException {
		try {
			HttpPost httpost = new HttpPost(SITE + "/session");
			httpost.setHeader("User-Agent", "android");

			List<NameValuePair> nvps = new ArrayList<NameValuePair>();
			nvps.add(new BasicNameValuePair("email", email));
			nvps.add(new BasicNameValuePair("password", password));
			httpost.setEntity(new UrlEncodedFormEntity(nvps, HTTP.UTF_8));

			HttpResponse response = httpclient.execute(httpost);
			String res = response.getStatusLine().toString();
			if ("HTTP/1.1 200 OK".equals(res)) {
				String info = IOUtils.toString(response.getEntity().getContent());
				AccountManager.login(httpclient.getCookieStore().getCookies(),info);
				return true;
			} else {
				return false;
			}
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			return false;
		} catch (ClientProtocolException e) {
			e.printStackTrace();
			throw new IntentException();
		} catch (IllegalStateException e) {
			e.printStackTrace();
			return false;
		} catch (IOException e) {
			e.printStackTrace();
			throw new IntentException();
		}
	}

	public static boolean send_feed(String title, String content,
			ArrayList<String> photo_names, ArrayList<Integer> select_collection_ids, boolean send_tsina) throws IntentException, AuthenticateException {
		try {
			String select_collection_ids_str = 
					BaseUtils.integer_list_to_string(select_collection_ids);
			String photo_string = BaseUtils.string_list_to_string(photo_names); 
			HttpPost httpost = new HttpPost(SITE + "/feeds");
			httpost.setHeader("User-Agent", "android");
			// …Ë÷√ params
			List<NameValuePair> nvps = new ArrayList<NameValuePair>();
			nvps.add(new BasicNameValuePair("content", title));
			nvps.add(new BasicNameValuePair("detail", content));
			nvps.add(new BasicNameValuePair("photo_names", photo_string));
			nvps.add(new BasicNameValuePair("collection_ids", select_collection_ids_str));
			if(send_tsina){
				nvps.add(new BasicNameValuePair("send_tsina", "true"));
			}
			httpost.setEntity(new UrlEncodedFormEntity(nvps, HTTP.UTF_8));

			set_cookie_store();
			HttpResponse response = httpclient.execute(httpost);
			response.getEntity().getContent().close();
			String res = response.getStatusLine().toString();
			if ("HTTP/1.1 200 OK".equals(res)) {
				return true;
			} else if("HTTP/1.1 401 Unauthorized".equals(res)){
				throw new AuthenticateException();
			}else {
				return false;
			}
		} catch (ClientProtocolException e) {
			e.printStackTrace();
			throw new IntentException();
		} catch (IOException e) {
			e.printStackTrace();
			throw new IntentException();
		}
	}
	
	public static String upload_photo(String image_path) throws IntentException, AuthenticateException{
		String photo_name = "";
		
		try {
			HttpPost httpost = new HttpPost(SITE + "/photos/feed_upload");
			httpost.setHeader("User-Agent", "android");
			MultipartEntity me = new MultipartEntity();
			File file = new File(image_path);
			FileBody bin = new FileBody(file, "image/jpeg");
			me.addPart("file", bin);
			httpost.setEntity(me);
			set_cookie_store();
			HttpResponse response = httpclient.execute(httpost);
			String res = response.getStatusLine().toString();
			if ("HTTP/1.1 200 OK".equals(res)) {
				photo_name = IOUtils.toString(response.getEntity()
						.getContent());
			}else if("HTTP/1.1 401 Unauthorized".equals(res)){
				throw new AuthenticateException();
			}
		} catch (ClientProtocolException e) {
			e.printStackTrace();
			throw new IntentException();
		} catch (IOException e) {
			e.printStackTrace();
			throw new IntentException();
		}
		
		return photo_name;
	}

	public static InputStream download_logo(String logo_url) {
		try {
			HttpGet httpget = new HttpGet(logo_url);
			httpget.setHeader("User-Agent", "android");
			set_cookie_store();
			HttpResponse response = httpclient.execute(httpget);
			String res = response.getStatusLine().toString();
			if ("HTTP/1.1 200 OK".equals(res)) {
				return response.getEntity().getContent();
			} else {
				return null;
			}
		} catch (ClientProtocolException e) {
			e.printStackTrace();
			return null;
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
	}

	public static boolean syn_data() throws IntentException, AuthenticateException {
		try {
			HttpGet httpget = new HttpGet(SITE + "/android_syn");
			httpget.setHeader("User-Agent", "android");
			set_cookie_store();
			HttpResponse response = httpclient.execute(httpget);
			String res = response.getStatusLine().toString();
			if ("HTTP/1.1 200 OK".equals(res)) {
				String json_string = IOUtils.toString(response.getEntity()
						.getContent());
				JSONObject json = new JSONObject(json_string);
				String collections = ((JSONArray)json.get("collections")).toString();
				String user_info = ((JSONObject)json.get("user")).toString();
				CollectionsCache.save(collections);
				AccountInfoCache.save(user_info);
			}else if("HTTP/1.1 401 Unauthorized".equals(res)){
				throw new AuthenticateException();
			}
			return true;
		}catch( JSONException e){
			e.printStackTrace();
			return false;
		} catch (ClientProtocolException e) {
			e.printStackTrace();
			throw new IntentException();
		} catch (IOException e) {
			e.printStackTrace();
			throw new IntentException();
		}
	}

	public static boolean create_collection(String title) throws IntentException, AuthenticateException {
		try {
			HttpPost httpost = new HttpPost(SITE + "/collections");
			httpost.setHeader("User-Agent", "android");
			
			List<NameValuePair> nvps = new ArrayList<NameValuePair>();
			nvps.add(new BasicNameValuePair("title", title));
			httpost.setEntity(new UrlEncodedFormEntity(nvps, HTTP.UTF_8));
			set_cookie_store();
			HttpResponse response = httpclient.execute(httpost);
			String res = response.getStatusLine().toString();
			if ("HTTP/1.1 200 OK".equals(res)) {
				String collections = IOUtils.toString(response.getEntity()
						.getContent());
				CollectionsCache.save(collections);
				return true;
			}else if("HTTP/1.1 401 Unauthorized".equals(res)){
				throw new AuthenticateException();
			}else{
				return false;
			}
		}catch (ClientProtocolException e) {
				e.printStackTrace();
				throw new IntentException();
			} catch (IOException e) {
				e.printStackTrace();
				throw new IntentException();
			}
	}

	public static List<HashMap<String, Object>> get_collection_feeds(int id) throws IntentException, AuthenticateException {
		ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String,Object>>();
		try {
			HttpGet httpget = new HttpGet(SITE + "/collections/" + id);
			httpget.setHeader("User-Agent", "android");
			set_cookie_store();
			HttpResponse response = httpclient.execute(httpget);
			String res = response.getStatusLine().toString();
			if ("HTTP/1.1 200 OK".equals(res)) {
				String json_str = IOUtils.toString(response.getEntity()
						.getContent());
				JSONArray feed_json_arr = new JSONArray(json_str);
				for (int i = 0; i < feed_json_arr.length(); i++) {
					JSONObject feed_json = feed_json_arr.getJSONObject(i);
					HashMap<String, Object> map = new HashMap<String, Object>();
					map.put("id", feed_json.get("id"));
					map.put("title", feed_json.get("title"));
					list.add(map);
				}
			}else if("HTTP/1.1 401 Unauthorized".equals(res)){
				throw new AuthenticateException();
			}
			return list;
		} catch (ClientProtocolException e) {
			e.printStackTrace();
			throw new IntentException();
		} catch (IOException e) {
			e.printStackTrace();
			throw new IntentException();
		}catch (JSONException e) {
			e.printStackTrace();
			throw new IntentException();
		}
	}
	
	public static boolean destroy_collection(int id) throws IntentException, AuthenticateException{
		try {
			HttpDelete httpdelete = new HttpDelete(SITE + "/collections/" + id);
			httpdelete.setHeader("User-Agent", "android");
			HttpResponse response;
			set_cookie_store();
			response = httpclient.execute(httpdelete);
			String res = response.getStatusLine().toString();
			if ("HTTP/1.1 200 OK".equals(res)) {
				String collections = IOUtils.toString(response.getEntity()
						.getContent());
				CollectionsCache.save(collections);
				return true;
			}else if("HTTP/1.1 401 Unauthorized".equals(res)){
				throw new AuthenticateException();
			} else {
				return false;
			}
		} catch (ClientProtocolException e) {
			e.printStackTrace();
			throw new IntentException();
		} catch (IOException e) {
			e.printStackTrace();
			throw new IntentException();
		}
	}
	
	public static boolean change_collection_name(int id, String title) throws IntentException, AuthenticateException{
		try {
			HttpPut httpput = new HttpPut(SITE + "/collections/" + id + "/change_name");
			httpput.setHeader("User-Agent", "android");
			
			List<NameValuePair> nvps = new ArrayList<NameValuePair>();
			nvps.add(new BasicNameValuePair("title", title));
			httpput.setEntity(new UrlEncodedFormEntity(nvps, HTTP.UTF_8));
			set_cookie_store();
			HttpResponse response = httpclient.execute(httpput);
			String res = response.getStatusLine().toString();
			if ("HTTP/1.1 200 OK".equals(res)) {
				String collections = IOUtils.toString(response.getEntity()
						.getContent());
				CollectionsCache.save(collections);
				return true;
			}else if("HTTP/1.1 401 Unauthorized".equals(res)){
				throw new AuthenticateException();
			} else {
				return false;
			}
		} catch (ClientProtocolException e) {
			e.printStackTrace();
			throw new IntentException();
		} catch (IOException e) {
			e.printStackTrace();
			throw new IntentException();
		}
	}
	
	public static HashMap<String, Object> read_feed(String feed_id) throws IntentException, AuthenticateException {
		HashMap<String, Object> map = null;
		try {
			HttpGet httpget = new HttpGet(SITE + "/feeds/" + feed_id);
			httpget.setHeader("User-Agent", "android");
			set_cookie_store();
			HttpResponse response = httpclient.execute(httpget);
			String res = response.getStatusLine().toString();
			if ("HTTP/1.1 200 OK".equals(res)) {
				String json_str = IOUtils.toString(response.getEntity()
						.getContent());
				JSONObject feed_json = new JSONObject(json_str);
				String id = feed_json.getString("id");
				String title = feed_json.getString("title");
				String detail = feed_json.getString("detail");
				JSONArray photos_json = feed_json.getJSONArray("photos");
				ArrayList<String> photos = new ArrayList<String>();
				for (int i = 0; i < photos_json.length(); i++) {
					String url = (String)photos_json.get(i);
					photos.add(url);
				}
				String creator_name = feed_json.getJSONObject("creator").getString("name");
				String creator_logo_url = feed_json.getJSONObject("creator").getString("logo_url");
				map = new HashMap<String, Object>();
				map.put("id",id);
				map.put("title",title);
				map.put("detail",detail);
				map.put("photos",photos);
				map.put("creator_name",creator_name);
				map.put("creator_logo_url",creator_logo_url);
			}else if("HTTP/1.1 401 Unauthorized".equals(res)){
				throw new AuthenticateException();
			}
			return map;
		} catch (ClientProtocolException e) {
			e.printStackTrace();
			throw new IntentException();
		}catch (IOException e) {
			e.printStackTrace();
			throw new IntentException();
		} catch (JSONException e) {
			e.printStackTrace();
			return map;
		}
	}
	
	private static void set_cookie_store(){
		httpclient.setCookieStore(AccountManager.get_cookie_store());
	}
	
	public static class IntentException extends Exception{
		private static final long serialVersionUID = -4969746083422993611L;
	}


}
