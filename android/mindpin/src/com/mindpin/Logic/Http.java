package com.mindpin.Logic;

import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.params.HttpClientParams;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpParams;
import org.json.JSONArray;
import org.json.JSONObject;
import com.mindpin.base.http.MindpinDeleteRequest;
import com.mindpin.base.http.MindpinGetRequest;
import com.mindpin.base.http.MindpinPostRequest;
import com.mindpin.base.http.MindpinPutRequest;
import com.mindpin.base.http.ParamFile;
import com.mindpin.base.utils.BaseUtils;
import com.mindpin.cache.CollectionsCache;
import com.mindpin.database.Feed;

public class Http {
	
	public static final String SITE = "http://dev.www.mindpin.com";
	private static HttpParams params = new BasicHttpParams(); 
	static{
		HttpClientParams.setRedirecting(params, false);  
	}
	public static DefaultHttpClient httpclient = new DefaultHttpClient(params);
	
	// ����·������
	public static final String �û���¼				= "/session";
	
	public static final String ͬ������ 			 	= "/api0/mobile_data_syn";
	public static final String �ҵ��ռ��������б� 	= "/api0/home_timeline";
	
	public static final String �ռ���������б� 		= "/api0/collections/feeds";
	public static final String �����ռ��� 			= "/api0/collections/create";
	public static final String ɾ���ռ��� 			= "/api0/collections/delete";
	public static final String �ռ������ 			= "/api0/collections/rename";
	
	public static final String �������� 				= "/api0/feeds/show";
	public static final String �������ı����� 		= "/api0/feeds/create";
	public static final String �ϴ�����ͼƬ 			= "/api0/feeds/upload_photo";
	public static final String ������ͼƬ���� 		= "/api0/feeds/create_with_photos";
	
	
	// LoginActivity
	// �û���¼����
	public static boolean user_authenticate(String email, String password) throws Exception {
		return new MindpinPostRequest<Boolean>(
			�û���¼, 
			new BasicNameValuePair("email", email),
			new BasicNameValuePair("password", password)		
		){
			@Override
			public Boolean on_success(String response_text) throws Exception{
				JSONObject json = new JSONObject(response_text);
				String user_info = ((JSONObject)json.get("user")).toString();
				AccountManager.login(httpclient.getCookieStore().getCookies(), user_info);
				return true;
			}
		}.go();
		
	}
	
	// MainActivity
	public static boolean mobile_data_syn() throws Exception {
		return new MindpinGetRequest<Boolean>(
			ͬ������
		){
			@Override
			public Boolean on_success(String response_text) throws Exception{
				JSONObject json = new JSONObject(response_text);
				String collections = ((JSONArray)json.get("collections")).toString();
				String user_info = ((JSONObject)json.get("user")).toString();
				Account.save(httpclient.getCookieStore().getCookies(), user_info);
				CollectionsCache.save(collections);
				return true;
			}
		}.go();
	}
	
	
	public static Void send_text_feed(String title,String detail,
			ArrayList<Integer> select_collection_ids, boolean send_tsina) throws Exception{
		
		String select_collection_ids_str = BaseUtils.integer_list_to_string(select_collection_ids);
		return new MindpinPostRequest<Void>(
			�������ı�����, 
			new BasicNameValuePair("title", title),
			new BasicNameValuePair("detail", detail),
			new BasicNameValuePair("collection_ids", select_collection_ids_str),
			new BasicNameValuePair("send_tsina", send_tsina ? "true":"false")
		){
			@Override
			public Void on_success(String response_text) throws Exception{
				return null;
			}
		}.go();
	}

	// ��������
	public static Void send_photo_feed(String title, String detail,
			ArrayList<String> photo_names, ArrayList<Integer> select_collection_ids, boolean send_tsina) throws Exception {
		
		String photo_string = BaseUtils.string_list_to_string(photo_names); 
		String select_collection_ids_str = BaseUtils.integer_list_to_string(select_collection_ids);
		
		return new MindpinPostRequest<Void>(
			������ͼƬ����, 
			new BasicNameValuePair("title", title),
			new BasicNameValuePair("detail", detail),
			new BasicNameValuePair("photo_names", photo_string),
			new BasicNameValuePair("collection_ids", select_collection_ids_str),
			new BasicNameValuePair("send_tsina", send_tsina ? "true":"false")
		){
			@Override
			public Void on_success(String response_text) throws Exception{
				return null;
			}
		}.go();
	}
	
	public static String upload_photo(String image_path) throws Exception{
		String upload_image_path = CompressPhoto.get_compress_file_path(image_path);
		return new MindpinPostRequest<String>(
			�ϴ�����ͼƬ,
			new ParamFile("file", upload_image_path, "image/jpeg")
		){

			@Override
			public String on_success(String response_text) throws Exception {
				return response_text;
			}
		}.go();
	}

	public static InputStream download_image(String logo_url) {
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

	public static boolean create_collection(String title) throws Exception {
		return new MindpinPostRequest<Boolean>(
				�����ռ���, 
				new BasicNameValuePair("title", title)
				){
			@Override
			public Boolean on_success(String response_text) throws Exception {
				CollectionsCache.save(response_text);
				return true;
			}
		}.go();
	}

	public static ArrayList<Feed> get_collection_feeds(int id) throws UnsupportedEncodingException, Exception {
		return new MindpinGetRequest<ArrayList<Feed>>(
				�ռ���������б�, 
				new BasicNameValuePair("collection_id", id+"")
				){
			@Override
			public ArrayList<Feed> on_success(String response_text) throws Exception {
				ArrayList<Feed> list = Feed.build_list_by_json(response_text);
				for (Feed feed : list) {
					Feed.create_or_update(feed.json);
				}
				return list;
			}
		}.go();
	}
	
	public static boolean destroy_collection(int id) throws Exception{
		return new MindpinDeleteRequest<Boolean>(
				ɾ���ռ���,
				new BasicNameValuePair("collection_id", id+"")){
			@Override
			public Boolean on_success(String response_text) throws Exception {
				CollectionsCache.save(response_text);
				return true;
			}
			
		}.go();
	}
	
	public static boolean change_collection_name(int id, String title) throws UnsupportedEncodingException, Exception{
		return new MindpinPutRequest<Boolean>(
				�ռ������,
				new BasicNameValuePair("title", title),
				new BasicNameValuePair("collection_id", id+"")){

					@Override
					public Boolean on_success(String response_text)
							throws Exception {
						CollectionsCache.save(response_text);
						return true;
					}
		}.go();
	}
	
	public static Feed read_feed(String feed_id) throws Exception {
		return new MindpinGetRequest<Feed>(
				��������,
				new BasicNameValuePair("id", feed_id)){

					@Override
					public Feed on_success(String response_text)
							throws Exception {
						Feed feed = Feed.build_by_json(response_text);
						Feed.create_or_update(feed.json);
						return feed;
					}
		}.go();
	}
	
	public static ArrayList<Feed> get_home_timeline_feeds(int max_id)
			throws Exception {
		BasicNameValuePair pair;
		if (max_id != -1) {
			pair = new BasicNameValuePair("max_id", max_id + "");
		} else {
			pair = new BasicNameValuePair("max_id", "");
		}
		return new MindpinGetRequest<ArrayList<Feed>>(�ҵ��ռ��������б�, pair) {

			@Override
			public ArrayList<Feed> on_success(String response_text)
					throws Exception {
				ArrayList<Feed> list = Feed.build_list_by_json(response_text);
				for (Feed feed : list) {
					Feed.create_or_update(feed.json);
				}
				return list;
			}
		}.go();
	}
	
	public static void set_cookie_store(){
		httpclient.setCookieStore(AccountManager.get_cookie_store());
	}
	
	public static class IntentException extends Exception{
		private static final long serialVersionUID = -4969746083422993611L;
	}


}
