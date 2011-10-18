package com.mindpin.runnable;

import android.app.Activity;
import android.content.Intent;
import android.os.AsyncTask;

import com.mindpin.R;
import com.mindpin.Logic.AccountManager.AuthenticateException;
import com.mindpin.activity.base.LoginActivity;
import com.mindpin.utils.BaseUtils;
import com.mindpin.widget.MindpinProgressDialog;

// 基本请求处理框架，构建于 AsyncTask 之上
public abstract class MindpinAsyncTask<TParams, TProgress, TResult> {
	
	public static final int SUCCESS = 200;
	public static final int AUTHENTICATE_EXCEPTION = 9003;
	public static final int UNKNOWN_EXCEPTION = 9099;
	
	
	private class InnerTask extends AsyncTask<TParams, TProgress, Integer>{
		
		@Override
		protected void onPreExecute(){
			// 如果构造器传入了 process_dialog_message 则显示一个提示框
			if(process_dialog_message != null){
				progress_dialog = MindpinProgressDialog.show(activity, process_dialog_message);
			}
			on_start();
		}
		
		@Override
		protected Integer doInBackground(TParams... params) {
			
			//publishProgress(null);
			
			try {
				System.out.println("开始执行");
				inner_task_result = do_in_background(params);
				return SUCCESS;
			}
			
			catch (AuthenticateException e){
				// 用户身份验证错误
				System.out.println("MindpinAsyncTask 用户身份验证错误");
				e.printStackTrace();
				return AUTHENTICATE_EXCEPTION;
			} 
			
			catch (Exception e){
				// 程序执行错误
				System.out.println("MindpinAsyncTask 程序执行错误");
				e.printStackTrace();
				return UNKNOWN_EXCEPTION;
			}
		}
		
		@Override
		protected void onPostExecute(Integer result) {
			try{
				switch (result) {
				case SUCCESS:
					//正确执行
					on_success(inner_task_result);
					break;
				case AUTHENTICATE_EXCEPTION:
					// 用户身份验证错误
					___authenticate_exception();
					break;
				case UNKNOWN_EXCEPTION:
					// 程序执行错误
					___unknown_exception();
					break;
				default:
					// result 传入了无法被处理的值，也算程序执行错误
					___unknown_exception();
					break;
				}
				
				___final();
			}catch(Exception e){
				// 如果最终处理过程中出现任何异常，也捕获之
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
			
			// 如果当前界面不是登录界面，则退回登录界面
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
	
	// 一般构造器，传入activity
	public MindpinAsyncTask(Activity activity){
		super();
		this.activity = activity;
	}
	// 构造器2，传入activity，以及process_dialog上面显示的文字
	public MindpinAsyncTask(Activity activity, String process_dialog_message){
		super();
		this.activity = activity;
		this.process_dialog_message = process_dialog_message;
	}
	// 构造器3，传入activity，以及process_dialog上面显示的文字的资源号
	public MindpinAsyncTask(Activity activity, int process_dialog_message_resource_id){
		super();
		this.activity = activity;
		this.process_dialog_message = activity.getResources().getString(process_dialog_message_resource_id);
	}
	
	
	// 调用该方法以执行异步请求
	public final void execute(TParams... params){
		this.inner_task = new InnerTask();
		this.inner_task.execute(params);
	}
	
	
	// 在do_in_background中调用该方法以调用 on_progress 方法
	public final void publish_progress(TProgress... values){
		this.inner_task.publish_progress(values);
	}
	
	// 必须实现此方法，声明异步请求中的方法逻辑
	public abstract TResult do_in_background(TParams... params) throws Exception;
	
	// 必须实现此方法，声明请求成功时的后续处理逻辑，包括界面的变化等
	public abstract void on_success(TResult result);
	
	// 选择实现此方法，声明请求开始时处理逻辑，包括界面的变化等
	// 例如显示进度条等
	public void on_start(){}
	
	// 选择实现此方法，声明请求完结时（不管正确还是出错时）的后续处理逻辑，包括界面的变化等
	// 例如关闭“正在登录…”对话框
	public void on_final(){}
	
	// 选择实现此方法，声明请求过程中随着进度变化的处理逻辑，包括界面的变化等
	// 例如更改进度条的进度
	public void on_progress_update(TProgress... values){}
	
	
	// 钩子方法，声明在登录认证错误时的一些特定处理逻辑
	public void on_authenticate_exception(){}
	// 钩子方法，声明在出现其他任何异常时的一些特定处理逻辑
	public boolean on_unknown_exception(){
		return true;
	}
}
