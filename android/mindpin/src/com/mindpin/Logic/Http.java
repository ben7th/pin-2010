package com.mindpin.Logic;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.io.IOUtils;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.client.params.HttpClientParams;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.HTTP;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.mindpin.Logic.AccountManager.AuthenticateException;
import com.mindpin.cache.AccountInfoCache;
import com.mindpin.cache.CollectionsCache;
import com.mindpin.utils.BaseUtils;

public class Http {
	
	public static final String SITE = "http://dev.www.mindpin.com";
	private static HttpParams params = new BasicHttpParams(); 
	static{
		HttpClientParams.setRedirecting(params, false);  
	}
	private static DefaultHttpClient httpclient = new DefaultHttpClient(params);
	
	
	// 用于发送post请求的类
	public static abstract class MindpinPostRequest<TResult> {
		private HttpPost http_post;
		
		// 一般文本参数的请求
		public MindpinPostRequest(final String request_path, final NameValuePair...nv_pairs) throws UnsupportedEncodingException{
			// 准备参数list对象
			List<NameValuePair> nv_pair_list = new ArrayList<NameValuePair>();
			for(NameValuePair pair : nv_pairs){
				nv_pair_list.add(pair);
			}
			
			// 构造http_post
			HttpPost http_post = new HttpPost(SITE + request_path);
			
			http_post.setHeader("User-Agent", "android");
			http_post.setEntity(new UrlEncodedFormEntity(nv_pair_list, HTTP.UTF_8));
			
			this.http_post = http_post;
		}
		
		// 上传文件之类的请求
		public MindpinPostRequest(final String request_path, final ParamFile...param_files){
			//准备参数
			MultipartEntity me = new MultipartEntity();
			for(ParamFile param_file : param_files){
				me.addPart(param_file.param_name, param_file.get_filebody());
			}
			
			// 构造http_post
			HttpPost http_post = new HttpPost(SITE + request_path);
			http_post.setHeader("User-Agent", "android");
			http_post.setEntity(me);
			
			this.http_post = http_post;
		}
		
		// 主方法 GO
		public TResult go() throws Exception{
			set_cookie_store();
			
			HttpResponse response = httpclient.execute(http_post);
			
			int status_code = response.getStatusLine().getStatusCode(); 
			
			InputStream res_content = response.getEntity().getContent();
			String responst_text = IOUtils.toString(res_content);
			
			res_content.close();
			
			switch(status_code){
			case HttpStatus.SC_OK:
				return on_success(responst_text);
			case HttpStatus.SC_UNAUTHORIZED:
				throw new AuthenticateException(); //抛出未登录异常，会被 MindpinRunnable 接到并处理
			default:
				throw new Exception();	//不是 200 也不是 401 只能认为是出错了。会被 MindpinRunnable 接到并处理
			}
		}
		
		// 此方法为 status_code = 200 时 的处理方法，由用户自己定义
		public abstract TResult on_success(String response_text) throws Exception;
	}
	
	// 用于包装文件以及文件MIME类型的小类
	public static class ParamFile{
		public String param_name;
		public String file_path;
		public String mime_type;
		
		public ParamFile(String param_name, String file_path, String mime_type){
			this.param_name = param_name;
			this.file_path = file_path;
			this.mime_type = mime_type;
		}
		
		public FileBody get_filebody(){
			File file = new File(file_path);
			return new FileBody(file, mime_type);
		}
	}
	
	/*LoginActivity*/
	
	// 用户登录请求
	public static boolean user_authenticate(String email, String password) throws Exception {
		return new MindpinPostRequest<Boolean>(
			"/session", 
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

	// 发送主题
	public static boolean send_feed(String title, String content,
			ArrayList<String> photo_names, ArrayList<Integer> select_collection_ids, boolean send_tsina) throws Exception {
		
		String photo_string = BaseUtils.string_list_to_string(photo_names); 
		String select_collection_ids_str = BaseUtils.integer_list_to_string(select_collection_ids);
		
		return new MindpinPostRequest<Boolean>(
			"/feeds", 
			new BasicNameValuePair("content", title),
			new BasicNameValuePair("detail", content),
			new BasicNameValuePair("photo_names", photo_string),
			new BasicNameValuePair("collection_ids", select_collection_ids_str),
			new BasicNameValuePair("send_tsina", send_tsina ? "true":"false")
		){
			@Override
			public Boolean on_success(String response_text) throws Exception{
				return true;
			}
		}.go();
	}
	
	public static String upload_photo(String image_path) throws Exception{
		String upload_image_path = CompressPhoto.get_compress_file_path(image_path);
		return new MindpinPostRequest<String>(
			"/photos/feed_upload",
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

	public static boolean mobile_data_syn() throws IntentException, AuthenticateException {
		try {
			HttpGet httpget = new HttpGet(SITE + "/api0/mobile_data_syn");
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
				return true;
			}else if("HTTP/1.1 401 Unauthorized".equals(res)){
				throw new AuthenticateException();
			}
			throw new IntentException();
		} catch (JSONException e) {
			e.printStackTrace();
			throw new IntentException();
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

	public static ArrayList<Feed> get_collection_feeds(int id) throws IntentException, AuthenticateException {
		ArrayList<Feed> list = new ArrayList<Feed>();
		try {
			HttpGet httpget = new HttpGet(SITE + "/api0/collection_feeds?collection_id=" + id);
			httpget.setHeader("User-Agent", "android");
			set_cookie_store();
			HttpResponse response = httpclient.execute(httpget);
			String res = response.getStatusLine().toString();
			if ("HTTP/1.1 200 OK".equals(res)) {
				String json_str = IOUtils.toString(response.getEntity()
						.getContent());
				list = Feed.build_by_collection_feeds_json(json_str);
				return list;
			}else if("HTTP/1.1 401 Unauthorized".equals(res)){
				throw new AuthenticateException();
			}
			throw new IntentException();
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
	
	public static Feed read_feed(String feed_id) throws IntentException, AuthenticateException {
		Feed feed = null;
		try {
			HttpGet httpget = new HttpGet(SITE + "/api0/show?id=" + feed_id);
			httpget.setHeader("User-Agent", "android");
			set_cookie_store();
			HttpResponse response = httpclient.execute(httpget);
			String res = response.getStatusLine().toString();
			if ("HTTP/1.1 200 OK".equals(res)) {
				String json_str = IOUtils.toString(response.getEntity()
						.getContent());
				feed = Feed.build_by_feed_detail_json(json_str);
				return feed;
			}else if("HTTP/1.1 401 Unauthorized".equals(res)){
				throw new AuthenticateException();
			}
			throw new IntentException();
		} catch (Exception e) {
			e.printStackTrace();
			throw new IntentException();
		}
	}
	
	private static void set_cookie_store(){
		httpclient.setCookieStore(AccountManager.get_cookie_store());
	}
	
	public static class IntentException extends Exception{
		private static final long serialVersionUID = -4969746083422993611L;
	}


}
