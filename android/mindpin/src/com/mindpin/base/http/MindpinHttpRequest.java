package com.mindpin.base.http;

import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.IOUtils;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.protocol.HTTP;

import com.mindpin.Logic.AccountManager;
import com.mindpin.Logic.AccountManager.AuthenticateException;
import com.mindpin.Logic.Http;

public abstract class MindpinHttpRequest<TResult> {
	protected HttpUriRequest http_uri_request;
	
	// ������ GO
	public TResult go() throws Exception{
		Http.set_cookie_store();
		
		HttpResponse response = Http.httpclient.execute(http_uri_request);
		
		int status_code = response.getStatusLine().getStatusCode(); 
		
		InputStream res_content = response.getEntity().getContent();
		String responst_text = IOUtils.toString(res_content);
		
		res_content.close();
		
		switch(status_code){
		case HttpStatus.SC_OK:
			return on_success(responst_text);
		case HttpStatus.SC_UNAUTHORIZED:
			on_authenticate_exception();
			clear_current_user_data();
			throw new AuthenticateException(); //�׳�δ��¼�쳣���ᱻ MindpinRunnable �ӵ�������
		default:
			throw new Exception();	//���� 200 Ҳ���� 401 ֻ����Ϊ�ǳ����ˡ��ᱻ MindpinRunnable �ӵ�������
		}
	}
	
	// �˷���Ϊ status_code = 200 ʱ �Ĵ����������û��Լ�����
	public abstract TResult on_success(String response_text) throws Exception;
	
	public void on_authenticate_exception(){/*nothing..*/};
	
	// ������¼ʧ��ʱ�������ǰ�û����û������¼����
	private void clear_current_user_data(){
		int user_id = AccountManager.current_user_id();
		if(user_id!=0){
			AccountManager.remove(user_id);
		}
	}
	
	protected String build_params_string(NameValuePair...nv_pairs){
		String params_string = "?";
				
		for(NameValuePair pair : nv_pairs){
			String name = pair.getName();
			String value = pair.getValue();
			params_string += (name + "=" + value + "&");
		}
		
		return params_string;
	}
	
	// һ�������ַ�������
	protected HttpEntity build_entity(NameValuePair...nv_pairs) throws UnsupportedEncodingException{
		List<NameValuePair> nv_pair_list = new ArrayList<NameValuePair>();
		for(NameValuePair pair : nv_pairs){
			nv_pair_list.add(pair);
		}
		return new UrlEncodedFormEntity(nv_pair_list, HTTP.UTF_8);
	}
}