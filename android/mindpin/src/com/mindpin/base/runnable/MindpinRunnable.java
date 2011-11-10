package com.mindpin.base.runnable;

import com.mindpin.Logic.AccountManager.AuthenticateException;
import com.mindpin.Logic.HttpApi.IntentException;

public abstract class MindpinRunnable implements Runnable {
	public static final int METHOD_NOT_DEFINE_EXCEPTION = 9001;
	public static final int INTENT_CONNECTION_EXCEPTION = 9002;
	public static final int AUTHENTICATE_EXCEPTION = 9003;
	public static final int UNKNOW_EXCEPTION = 9099;
	
	private MindpinHandler handler;
	public MindpinRunnable(MindpinHandler handler){
		this.handler = handler;
	}
	
	@Override
	public void run() {
		try {
			mindpin_run();
		} 
		
		// ���ֵ��͵�ȫ��ͨ�ô���
		catch (MethodNotDefineException e) {
			// ����û�ж��壬ͨ�����ڹ���δʵ��ʱ
			handler.sendEmptyMessage(METHOD_NOT_DEFINE_EXCEPTION);
			e.printStackTrace();
		} 
		
		catch (IntentException e){
			// �������Ӵ���
			if(on_intent_connection_exception()){
				handler.sendEmptyMessage(INTENT_CONNECTION_EXCEPTION);
			}
			e.printStackTrace();
		} 
		
		catch (AuthenticateException e){
			// �û������֤����
			handler.sendEmptyMessage(AUTHENTICATE_EXCEPTION);
			e.printStackTrace();
		} 
		
		catch (Exception e){
			// ����ִ�д���
			if(on_exception()){;
				handler.sendEmptyMessage(UNKNOW_EXCEPTION);
			}
			e.printStackTrace();
		}
	}
	
	public abstract void mindpin_run() throws Exception;
	
	public boolean on_intent_connection_exception(){
		return true;
		// do nothing .. ���������ظ÷���
		// ����ʱ ��� 
		// return true   ����Ȼ���� message UNKNOW_EXCEPTION
		// return false  ���ٷ��� message UNKNOW_EXCEPTION
	}
	
	public boolean on_exception(){
		return true;
		// do nothing .. ���������ظ÷���
		// ����ʱ ��� 
		// return true   ����Ȼ���� message UNKNOW_EXCEPTION
		// return false  ���ٷ��� message UNKNOW_EXCEPTION
	}
	
	public class MethodNotDefineException extends Exception{
		private static final long serialVersionUID = -1400532382871315093L;
	}
}
