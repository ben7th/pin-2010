package com.mindpin.runnable;

import android.app.Activity;
import android.content.Intent;
import android.os.AsyncTask;

import com.mindpin.R;
import com.mindpin.Logic.AccountManager.AuthenticateException;
import com.mindpin.activity.base.LoginActivity;
import com.mindpin.utils.BaseUtils;
import com.mindpin.widget.MindpinProgressDialog;

// �����������ܣ������� AsyncTask ֮��
public abstract class MindpinAsyncTask<TParams, TProgress, TResult> {
	
	public static final int SUCCESS = 200;
	public static final int AUTHENTICATE_EXCEPTION = 9003;
	public static final int UNKNOWN_EXCEPTION = 9099;
	
	
	private class InnerTask extends AsyncTask<TParams, TProgress, Integer>{
		
		@Override
		protected void onPreExecute(){
			// ��������������� process_dialog_message ����ʾһ����ʾ��
			if(process_dialog_message != null){
				progress_dialog = MindpinProgressDialog.show(activity, process_dialog_message);
			}
			on_start();
		}
		
		@Override
		protected Integer doInBackground(TParams... params) {
			
			//publishProgress(null);
			
			try {
				System.out.println("��ʼִ��");
				inner_task_result = do_in_background(params);
				return SUCCESS;
			}
			
			catch (AuthenticateException e){
				// �û������֤����
				System.out.println("MindpinAsyncTask �û������֤����");
				e.printStackTrace();
				return AUTHENTICATE_EXCEPTION;
			} 
			
			catch (Exception e){
				// ����ִ�д���
				System.out.println("MindpinAsyncTask ����ִ�д���");
				e.printStackTrace();
				return UNKNOWN_EXCEPTION;
			}
		}
		
		@Override
		protected void onPostExecute(Integer result) {
			try{
				switch (result) {
				case SUCCESS:
					//��ȷִ��
					on_success(inner_task_result);
					break;
				case AUTHENTICATE_EXCEPTION:
					// �û������֤����
					___authenticate_exception();
					break;
				case UNKNOWN_EXCEPTION:
					// ����ִ�д���
					___unknown_exception();
					break;
				default:
					// result �������޷��������ֵ��Ҳ�����ִ�д���
					___unknown_exception();
					break;
				}
				
				___final();
			}catch(Exception e){
				// ������մ�������г����κ��쳣��Ҳ����֮
				___unknown_exception();
			}
		}
		
		@Override
		protected void onProgressUpdate(TProgress... values) {
			on_progress_update(values);
		};
		
		protected void publish_progress(TProgress... values){
			publishProgress(values);
		}
		
		private void ___authenticate_exception(){
			on_authenticate_exception();
			
			BaseUtils.toast(R.string.app_authenticate_exception);
			
			// �����ǰ���治�ǵ�¼���棬���˻ص�¼����
			if(activity.getClass() != LoginActivity.class){
				activity.startActivity(new Intent(activity, LoginActivity.class));
				activity.finish();
			}
		}
		
		private void ___unknown_exception(){
			if(on_unknown_exception()){
				BaseUtils.toast(R.string.app_unknown_exception);
			}
		}
		
		private void ___final(){
			on_final();
			if(progress_dialog != null){
				progress_dialog.dismiss();
			}
		}
	}
	
	private Activity activity = null;
	private String process_dialog_message = null;
	private MindpinProgressDialog progress_dialog = null;
	
	private InnerTask inner_task = null;
	private TResult inner_task_result = null;
	
	// һ�㹹����������activity
	public MindpinAsyncTask(Activity activity){
		super();
		this.activity = activity;
	}
	// ������2������activity���Լ�process_dialog������ʾ������
	public MindpinAsyncTask(Activity activity, String process_dialog_message){
		super();
		this.activity = activity;
		this.process_dialog_message = process_dialog_message;
	}
	// ������3������activity���Լ�process_dialog������ʾ�����ֵ���Դ��
	public MindpinAsyncTask(Activity activity, int process_dialog_message_resource_id){
		super();
		this.activity = activity;
		this.process_dialog_message = activity.getResources().getString(process_dialog_message_resource_id);
	}
	
	
	// ���ø÷�����ִ���첽����
	public final void execute(TParams... params){
		this.inner_task = new InnerTask();
		this.inner_task.execute(params);
	}
	
	
	// ��do_in_background�е��ø÷����Ե��� on_progress ����
	public final void publish_progress(TProgress... values){
		this.inner_task.publish_progress(values);
	}
	
	// ����ʵ�ִ˷����������첽�����еķ����߼�
	public abstract TResult do_in_background(TParams... params) throws Exception;
	
	// ����ʵ�ִ˷�������������ɹ�ʱ�ĺ��������߼�����������ı仯��
	public abstract void on_success(TResult result);
	
	// ѡ��ʵ�ִ˷�������������ʼʱ�����߼�����������ı仯��
	// ������ʾ��������
	public void on_start(){}
	
	// ѡ��ʵ�ִ˷����������������ʱ��������ȷ���ǳ���ʱ���ĺ��������߼�����������ı仯��
	// ����رա����ڵ�¼�����Ի���
	public void on_final(){}
	
	// ѡ��ʵ�ִ˷���������������������Ž��ȱ仯�Ĵ����߼�����������ı仯��
	// ������Ľ������Ľ���
	public void on_progress_update(TProgress... values){}
	
	
	// ���ӷ����������ڵ�¼��֤����ʱ��һЩ�ض������߼�
	public void on_authenticate_exception(){}
	// ���ӷ����������ڳ��������κ��쳣ʱ��һЩ�ض������߼�
	public boolean on_unknown_exception(){
		return true;
	}
}
