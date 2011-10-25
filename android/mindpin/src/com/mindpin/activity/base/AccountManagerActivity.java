package com.mindpin.activity.base;

import java.util.ArrayList;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.HeaderViewListAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.mindpin.R;
import com.mindpin.Logic.AccountManager;
import com.mindpin.application.MindpinApplication;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.database.User;
import com.mindpin.widget.AccountListAdapter;

public class AccountManagerActivity extends MindpinBaseActivity {
	
	private ListView list_view;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.base_account_manager);
		list_view = (ListView)findViewById(R.id.account_list);
		
		bind_add_account_event();
		fill_list();
		
	}

	// 填充账号列表信息，并给列表绑定点击事件
	private void fill_list() {
		list_view.setAdapter(new AccountListAdapter(this));
		list_view.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				TextView id_textview = (TextView)view.findViewById(R.id.account_id);
				String user_id = (String)id_textview.getText();
				AccountManager.switch_account(Integer.parseInt(user_id));
				startActivity(new Intent(AccountManagerActivity.this,MainActivity.class));
				AccountManagerActivity.this.finish();
			}
		});
	}
	
	// 设置 增加账号按钮事件
	private void bind_add_account_event() {
		View footer_view = getLayoutInflater().inflate(R.layout.list_account_footer, null);
		list_view.addFooterView(footer_view);
		View button = footer_view.findViewById(R.id.add_account);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				startActivity(new Intent(AccountManagerActivity.this,LoginActivity.class));
			}
		});
	}
	
	// 设置 账号列表的编辑模式
	public void edit_account(View view){
		Button button = (Button)view;
		AccountListAdapter account_list_adapter = (AccountListAdapter)((HeaderViewListAdapter) list_view
				.getAdapter()).getWrappedAdapter(); // why?
		
		if(account_list_adapter.is_edit_mode()){
			account_list_adapter.close_edit_mode();
			button.setText(R.string.account_edit_button);
		}else{
			account_list_adapter.open_edit_mode();
			button.setText(R.string.account_edit_button_close);
		}
	}
	
//	@Override  
//	public boolean onKeyDown(int keyCode, KeyEvent event) {  
//	    if(keyCode == KeyEvent.KEYCODE_BACK){
//			int id = AccountManager.current_user_id();
//			if(0 == id){
//				if(User.get_count() != 0){
//					ArrayList<User> users = User.get_users();
//					User user = users.get(0);
//					AccountManager.switch_account(user.user_id);
//					startActivity(new Intent(AccountManagerActivity.this,MainActivity.class));
//					this.finish();
//				}else{
//					go_to_login();
//				}
//				return true;				
//			}
//	    }  
//	    return super.onKeyDown(keyCode, event);  
//	}
	
	public void go_to_login() {
		MainActivity activity = ((MindpinApplication)getApplication()).get_main_activity();
		activity.finish();
		startActivity(new Intent(AccountManagerActivity.this,LoginActivity.class));
//		this.finish();
	}
	
	@Override
	protected void onDestroy() {
		int id = AccountManager.current_user_id();
		if (0 == id) {
			if (User.count() != 0) {
				ArrayList<User> users = User.all();
				User user = users.get(0);
				AccountManager.switch_account(user.user_id);
				startActivity(new Intent(AccountManagerActivity.this,
						MainActivity.class));
//				this.finish();
			} else {
				go_to_login();
			}
		}
		
		
		super.onDestroy();
	}
	
}
