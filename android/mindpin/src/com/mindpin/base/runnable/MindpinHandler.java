package com.mindpin.base.runnable;

import android.app.Activity;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.widget.Toast;

import com.mindpin.R;
import com.mindpin.activity.base.LoginActivity;
import com.mindpin.application.MindpinApplication;

public abstract class MindpinHandler extends Handler {
	private Activity activity;
	
	public MindpinHandler(Activity activity){
		super();
		this.activity = activity;
	}
	
	@Override
	public void handleMessage(Message msg) {
		super.handleMessage(msg);
		
		boolean is_success = mindpin_handle_message(msg);
		
		if(!is_success){
			switch (msg.what) {
			case MindpinRunnable.METHOD_NOT_DEFINE_EXCEPTION:
				// ����û�ж���
				Toast.makeText(
					MindpinApplication.context, 
					R.string.app_method_not_define_exception,
					Toast.LENGTH_SHORT
				).show();
				break;
			case MindpinRunnable.INTENT_CONNECTION_EXCEPTION:
				// �������Ӵ���
				Toast.makeText(
					MindpinApplication.context, 
					R.string.app_intent_connection_exception,
					Toast.LENGTH_SHORT
				).show();
				
				on_intent_connection_exception();
				
				break;
			case MindpinRunnable.AUTHENTICATE_EXCEPTION:
				// �û������֤����
				Toast.makeText(
					MindpinApplication.context, 
					R.string.app_authenticate_exception,
					Toast.LENGTH_SHORT
				).show();
				
				if(activity.getClass() != LoginActivity.class){
					activity.startActivity(new Intent(activity, LoginActivity.class));
					activity.finish();
				}
				
				break;
			case MindpinRunnable.UNKNOW_EXCEPTION:
				// ����ִ�д���
				Toast.makeText(
					MindpinApplication.context, 
					R.string.app_unknown_exception,
					Toast.LENGTH_SHORT
				).show();
				break;
			default:
				// message.what �������޷��������ֵ��Ҳ�����ִ�д���
				Toast.makeText(
					MindpinApplication.context, 
					R.string.app_unknown_exception,
					Toast.LENGTH_SHORT
				).show();
				break;
			}
		}
	}
	
	public abstract boolean mindpin_handle_message(Message msg);
	
	public void on_intent_connection_exception(){
		//do nothing
		//�����߿����������ش˷���
	};
}
