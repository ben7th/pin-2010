package com.mindpin.base.task;

import android.os.AsyncTask;
import android.util.Log;

import com.mindpin.R;
import com.mindpin.Logic.AccountManager.AuthenticateException;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.base.utils.BaseUtils;
import com.mindpin.widget.MindpinProgressDialog;

// �����������ܣ������� AsyncTask ֮��
public abstract class MindpinAsyncTask<TParams, TProgress, TResult> {
	
	public static final int SUCCESS = 200;
	public static final int AUTHENTICATE_EXCEPTION = 9003;
	public static final int UNKNOWN_EXCEPTION = 9099;
	
	
	private class InnerTask extends AsyncTask<TParams, TProgress, Integer>{
		
		@Override
		protected void onPreExecute(){
			// ��������������� progress_dialog_message ����ʾһ����ʾ��
			if(null != progress_dialog_message && null != progress_dialog_activity){
				progress_dialog = MindpinProgressDialog.show(progress_dialog_activity, progress_dialog_message);
			}
			on_start();
		}
		
		@Override
		protected Integer doInBackground(TParams... params) {
			
			//publishProgress(null);
			
			try {
				Log.d("MindpinAsyncTask","��ʼִ��");
				inner_task_result = do_in_background(params);
				return SUCCESS;
			}
			
			catch (AuthenticateException e){
				// �û������֤����
				Log.e("MindpinAsyncTask","�û������֤����");
				e.printStackTrace();
				return AUTHENTICATE_EXCEPTION;
			} 
			
			catch (Exception e){
				// ����ִ�д���
				Log.e("MindpinAsyncTask","����ִ�д���");
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
			}catch(Exception e){
				e.printStackTrace();
				// ������մ�������г����κ��쳣��Ҳ����֮
				___unknown_exception();
			}finally{
				___final();
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
			
			// 2011.10.27 ���ٶ��û������֤�������������Զ�����
		}
		
		private void ___unknown_exception(){
			if(on_unknown_exception()){
				BaseUtils.toast(R.string.app_unknown_exception);
			}
		}
		
		private void ___final(){
			on_final();
			if(null != progress_dialog){
				progress_dialog.dismiss();
			}
		}
	}
	
	
	private MindpinBaseActivity progress_dialog_activity = null;
	private String progress_dialog_message = null;
	private MindpinProgressDialog progress_dialog = null;
	
	private InnerTask inner_task = null;
	private TResult inner_task_result = null;
	
	// һ�㹹������ʲô�����ô�
	public MindpinAsyncTask(){
		super();
	}
	// ������2������activity���Լ� progress_dialog ������ʾ������
	// ������ʾ progress dialog �����õ�activity�����Դ�����
	public MindpinAsyncTask(MindpinBaseActivity progress_dialog_activity, String process_dialog_message){
		super();
		this.progress_dialog_activity = progress_dialog_activity;
		this.progress_dialog_message = process_dialog_message;
	}
	// ������3������activity���Լ� progress_dialog ������ʾ�����ֵ���Դ��
	// ������ʾ progress dialog �����õ�activity�����Դ�����
	public MindpinAsyncTask(MindpinBaseActivity progress_dialog_activity, int process_dialog_message_resource_id){
		super();
		this.progress_dialog_activity = progress_dialog_activity;
		this.progress_dialog_message = progress_dialog_activity.getResources().getString(process_dialog_message_resource_id);
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
