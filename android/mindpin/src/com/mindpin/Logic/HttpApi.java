package com.mindpin.Logic;

import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONObject;

import android.location.Location;

import com.mindpin.base.http.MindpinDeleteRequest;
import com.mindpin.base.http.MindpinGetRequest;
import com.mindpin.base.http.MindpinHttpRequest;
import com.mindpin.base.http.MindpinPostRequest;
import com.mindpin.base.http.MindpinPutRequest;
import com.mindpin.base.http.ParamFile;
import com.mindpin.base.utils.BaseUtils;
import com.mindpin.model.AccountUser;
import com.mindpin.model.ContactUser;
import com.mindpin.model.Feed;
import com.mindpin.model.FeedComment;
import com.mindpin.model.cache.CollectionsCache;
import com.mindpin.model.database.AccountUserDBHelper;
import com.mindpin.model.database.FeedDBHelper;

public class HttpApi {
	
	public static final String SITE = "http://www.mindpin.com";
	
	// ����·������
	public static final String �û���¼				= "/login";
	
	public static final String ͬ������ 			    = "/api0/mobile_data_syn";
	public static final String �ҵ��ռ��������б� 	= "/api0/home_timeline";
	
	public static final String �ռ���������б� 		= "/api0/collections/feeds";
	public static final String �����ռ��� 			= "/api0/collections/create";
	public static final String ɾ���ռ��� 			= "/api0/collections/delete";
	public static final String �ռ������ 			= "/api0/collections/rename";
	
	public static final String ��������				= "/api0/feeds/show";
	public static final String �������� 		= "/api0/feeds/create";
	public static final String �ϴ�����ͼƬ 			= "/api0/feeds/upload_photo";
	
	public static final String ������������			= "/api0/comments/create";
	public static final String ����������б�		= "/api0/comments/list";
	public static final String ɾ����������			= "/api0/comments/delete";
	public static final String �ظ���������			= "/api0/comments/reply";
	public static final String ��ǰ�û��յ�������    = "/api0/comments/received";
	
	public static final String �û��Ĺ�ע�б�		= "/api0/contacts/followings";
	
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
				AccountManager.login(get_cookies(), user_info);
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
				
				AccountUserDBHelper.save(new AccountUser(get_cookies(), user_info));
				CollectionsCache.save(collections);
				return true;
			}
		}.go();
	}
	
	
	public static Void send_text_feed(String title, String detail, 
			List<Integer> select_collection_ids, boolean send_tsina, Location current_location) throws Exception{
		
		String select_collection_ids_str = BaseUtils.integer_list_to_string(select_collection_ids);
		return new MindpinPostRequest<Void>(
				��������, 
			new BasicNameValuePair("title", title),
			new BasicNameValuePair("detail", detail),
			new BasicNameValuePair("collection_ids", select_collection_ids_str),
			new BasicNameValuePair("send_tsina", send_tsina ? "true":"false"),
			new BasicNameValuePair("location", BaseUtils.location_to_string(current_location))
		){
			@Override
			public Void on_success(String response_text) throws Exception{
				return null;
			}
		}.go();
	}

	// ��������
	public static Void send_photo_feed(String title, String detail,
			List<Integer> photo_ids, List<Integer> select_collection_ids, boolean send_tsina, Location current_location) throws Exception {
		
		String photo_string = BaseUtils.integer_list_to_string(photo_ids); 
		String select_collection_ids_str = BaseUtils.integer_list_to_string(select_collection_ids);
		
		return new MindpinPostRequest<Void>(
				��������, 
			new BasicNameValuePair("title", title),
			new BasicNameValuePair("detail", detail),
			new BasicNameValuePair("photo_ids", photo_string),
			new BasicNameValuePair("collection_ids", select_collection_ids_str),
			new BasicNameValuePair("send_tsina", send_tsina ? "true":"false"),
			new BasicNameValuePair("location", BaseUtils.location_to_string(current_location))
		){
			@Override
			public Void on_success(String response_text) throws Exception{
				return null;
			}
		}.go();
	}
	
	public static Integer upload_photo(String image_path) throws Exception{
		String upload_image_path = CompressPhoto.get_compress_file_path(image_path);
		return new MindpinPostRequest<Integer>(
			�ϴ�����ͼƬ,
			new ParamFile("file", upload_image_path, "image/jpeg")
		){

			@Override
			public Integer on_success(String response_text) throws Exception {
				JSONObject json = new JSONObject(response_text);
				return json.getInt("photo_id");
			}
		}.go();
	}

	public static InputStream download_image(String image_url) {
		try {
			HttpGet httpget = new HttpGet(image_url);
			httpget.setHeader("User-Agent", "android");
			HttpResponse response = MindpinHttpRequest.get_httpclient_instance().execute(httpget);
			int status_code = response.getStatusLine().getStatusCode();
			if (HttpStatus.SC_OK == status_code) {
				return response.getEntity().getContent();
			} else {
				return null;
			}
		} catch (Exception e) {
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
	
	public static boolean destroy_collection(Integer collection_id) throws Exception{
		return new MindpinDeleteRequest<Boolean>(
				ɾ���ռ���,
				new BasicNameValuePair("collection_id", collection_id.toString())){
			@Override
			public Boolean on_success(String response_text) throws Exception {
				CollectionsCache.save(response_text);
				return true;
			}
			
		}.go();
	}
	
	public static boolean change_collection_name(Integer collection_id, String title) throws UnsupportedEncodingException, Exception{
		return new MindpinPutRequest<Boolean>(
				�ռ������,
				new BasicNameValuePair("title", title),
				new BasicNameValuePair("collection_id", collection_id.toString())){

					@Override
					public Boolean on_success(String response_text)
							throws Exception {
						CollectionsCache.save(response_text);
						return true;
					}
		}.go();
	}
	
	public static Feed read_feed(Integer feed_id) throws Exception {
		return new MindpinGetRequest<Feed>(
				��������,
				new BasicNameValuePair("id", feed_id.toString())){

					@Override
					public Feed on_success(String response_text)
							throws Exception {
						Feed feed = Feed.build(response_text);
						FeedDBHelper.create_or_update(feed);
						return feed;
					}
		}.go();
	}
	
	public static boolean add_feed_commment(Integer feed_id, String content) throws UnsupportedEncodingException, Exception{
		return new MindpinPostRequest<Boolean>(
				������������, 
				new BasicNameValuePair("feed_id", feed_id.toString()),
				new BasicNameValuePair("content", content)
				){
			@Override
			public Boolean on_success(String response_text) throws Exception {
				return true;
			}
		}.go();
	}
	
	public static List<FeedComment> get_feed_comments(Integer feed_id) throws Exception{
		return new MindpinGetRequest<List<FeedComment>>(
				����������б�, 
				new BasicNameValuePair("feed_id", feed_id.toString())
				){
			@Override
			public List<FeedComment> on_success(String response_text) throws Exception {
				return FeedComment.build_list_by_json(response_text);
			}
		}.go();
	}
	
	public static void destroy_feed_commment(Integer comment_id) throws Exception{
		new MindpinDeleteRequest<Void>(
				ɾ����������,
				new BasicNameValuePair("comment_id", comment_id.toString())
				) {
			@Override
			public Void on_success(String response_text) throws Exception {
				return null;
			}
		}.go();
	}
	
	public static Boolean reply_feed_comment(Integer comment_id, String content) throws Exception{
		return new MindpinPostRequest<Boolean>(
				�ظ���������,
				new BasicNameValuePair("comment_id", comment_id.toString()),
				new BasicNameValuePair("content", content)
				) {
			public Boolean on_success(String response_text) throws Exception {
				return true;
			};
		}.go();
	}
	
	public static List<FeedComment> received_comments() throws Exception{
		return received_comments(-1);
	}
	
	public static List<FeedComment> received_comments(Integer max_id) throws Exception{
		BasicNameValuePair param;
		if (max_id > 0) {
			param = new BasicNameValuePair("max_id", max_id.toString());
		} else {
			param = new BasicNameValuePair("max_id", "");
		}
		return new MindpinGetRequest<List<FeedComment>>(
				��ǰ�û��յ�������,
				param
				) {
					@Override
					public List<FeedComment> on_success(
							String response_text) throws Exception {
						return FeedComment.build_list_by_json(response_text);
					}
		}.go();
	}
	
	public static List<ContactUser> get_current_user_followings() throws Exception{
		return get_followings(AccountManager.current_user().user_id);
	}
	
	public static List<ContactUser> get_followings(Integer user_id)
			throws Exception {
		return new MindpinGetRequest<List<ContactUser>>(
			�û��Ĺ�ע�б�,
			new BasicNameValuePair("user_id", user_id.toString())
		) {
			@Override
			public List<ContactUser> on_success(String response_text)
					throws Exception {
				return ContactUser.build_list_by_json(response_text);
			}
		}.go();
	}
	
	public static class IntentException extends Exception{
		private static final long serialVersionUID = -4969746083422993611L;
	}

	public static class FeedsApi{
		public static List<Feed> get_home_timeline() throws Exception{
			return request_�ҵ��ռ��������б�();
		}
		public static List<Feed> get_home_timeline(Integer max_id) throws Exception {
			BasicNameValuePair param = new BasicNameValuePair("max_id", max_id.toString());
			return request_�ҵ��ռ��������б�(param);
		}
		private static List<Feed> request_�ҵ��ռ��������б�(BasicNameValuePair... param) throws Exception{
			return new MindpinGetRequest<List<Feed>>(�ҵ��ռ��������б�, param) {

				@Override
				public List<Feed> on_success(String response_text)
						throws Exception {
					List<Feed> feeds = Feed.build_list_by_json(response_text);
					for (Feed feed : feeds) {
						FeedDBHelper.create_or_update(feed);
					}
					return feeds;
				}
			}.go();
		}
	}

	public static class CollectionApi{
		public static List<Feed> get_collection_feeds(int collection_id) throws Exception {
			return request_�ռ���������б�(collection_id, -1);
		}

		public static List<Feed> get_collection_feeds(int collection_id, int max_id) throws Exception {
			return request_�ռ���������б�(collection_id, max_id);
		}
		private static List<Feed> request_�ռ���������б�(Integer collection_id, Integer max_id) throws Exception{			
			return new MindpinGetRequest<List<Feed>>(
					�ռ���������б�, 
					new BasicNameValuePair("collection_id", collection_id.toString()),
					new BasicNameValuePair("max_id", ( max_id > 0 ? max_id.toString() : ""))
			){
				@Override
				public List<Feed> on_success(String response_text) throws Exception {
					List<Feed> list = Feed.build_list_by_json(response_text);
					for (Feed feed : list) {
						FeedDBHelper.create_or_update(feed);
					}
					return list;
				}
			}.go();
		}
	}
}
