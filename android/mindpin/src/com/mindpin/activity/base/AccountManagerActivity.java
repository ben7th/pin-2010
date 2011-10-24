package com.mindpin.activity.base;

import java.util.ArrayList;
import com.mindpin.R;
import com.mindpin.Logic.AccountManager;
import com.mindpin.application.MindpinApplication;
import com.mindpin.database.User;
import com.mindpin.widget.AccountListAdapter;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.HeaderViewListAdapter;
import android.widget.ListView;
import android.widget.TextView;

public class AccountManagerActivity extends Activity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.account_manager);
		
		ListView lv = (ListView)findViewById(R.id.account_list);
		// 设置 增加账号按钮
		View footer_view = getLayoutInflater().inflate(R.layout.account_item_add_account_button, null);
		lv.addFooterView(footer_view);
		View button = footer_view.findViewById(R.id.add_account);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				startActivity(new Intent(AccountManagerActivity.this,LoginActivity.class));
				AccountManagerActivity.this.finish();
			}
		});
		// 列出账号信息
		lv.setAdapter(new AccountListAdapter(this));
		lv.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				TextView id_tv = (TextView)view.findViewById(R.id.account_id);
				String user_id = (String)id_tv.getText();
				AccountManager.switch_account(Integer.parseInt(user_id));
				startActivity(new Intent(AccountManagerActivity.this,MainActivity.class));
				AccountManagerActivity.this.finish();
			}
		});
		
		// 设置 账号列表的编辑模式
		final AccountListAdapter account_list_adapter = (AccountListAdapter) ((HeaderViewListAdapter) lv
				.getAdapter()).getWrappedAdapter();
		Button edit_bn = (Button)findViewById(R.id.account_edit);
		edit_bn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Button bn = (Button)v;
				if(account_list_adapter.is_edit_mode()){
					account_list_adapter.close_edit_mode();
					bn.setText(R.string.account_edit);
				}else{
					account_list_adapter.open_edit_mode();
					bn.setText(R.string.account_edit_end);
				}
			}
		});
	}
	
	
	@Override  
	public boolean onKeyDown(int keyCode, KeyEvent event) {  
	    if(keyCode == KeyEvent.KEYCODE_BACK){
			int id = AccountManager.current_user_id();
			if(0 == id){
				if(User.get_count() != 0){
					ArrayList<User> users = User.get_users();
					User user = users.get(0);
					AccountManager.switch_account(user.user_id);
					startActivity(new Intent(AccountManagerActivity.this,MainActivity.class));
					this.finish();
				}else{
					go_to_login();
				}
				return true;				
			}
	    }  
	    return super.onKeyDown(keyCode, event);  
	}
	
	public void go_to_login() {
		MainActivity activity = ((MindpinApplication)getApplication()).get_main_activity();
		activity.finish();
		startActivity(new Intent(AccountManagerActivity.this,LoginActivity.class));
		this.finish();
	}
}
