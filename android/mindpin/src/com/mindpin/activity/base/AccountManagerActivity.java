package com.mindpin.activity.base;

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

import com.mindpin.R;
import com.mindpin.Logic.AccountManager;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.database.User;
import com.mindpin.widget.adapter.AccountListAdapter;

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
				User user = User.find(Integer.parseInt(user_id));
				AccountManager.switch_account(user);
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
				open_login();
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
	
	@Override
	// 硬返回按钮
	public boolean onKeyDown(int keyCode, KeyEvent event) {  
	    if(keyCode == KeyEvent.KEYCODE_BACK){
	    	on_account_manager_activity_go_back();
			this.finish();
			return true;				
	    }  
	    return super.onKeyDown(keyCode, event);  
	}
	
	// 软返回回调
	@Override
	public void on_go_back() {
		super.on_go_back();
		on_account_manager_activity_go_back();
	}
	
	private void on_account_manager_activity_go_back(){
		// 由于可能在删除用户时，删除了当前正登录的用户，所以 is_logged_in()会返回false
		if (!is_logged_in()) {
			if (User.count() > 0) {
				// 如果还有用户，则选择所有用户中的第一个，切换之
				AccountManager.switch_account(User.all().get(0));
				// open main_activity 堆栈会被MindpinBaseActivity自动清理
				open_activity(MainActivity.class);
			} else {
				// 如果没有用户了，则关闭所有已经打开的界面，再打开登录界面
				restart_to_login();
			}
		}
	}
	
	public void open_login(){
		open_activity(LoginActivity.class);
	}
	
}
