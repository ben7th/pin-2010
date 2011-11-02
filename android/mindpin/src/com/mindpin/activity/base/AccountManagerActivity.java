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

	// ����˺��б���Ϣ�������б�󶨵���¼�
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
	
	// ���� �����˺Ű�ť�¼�
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
	
	// ���� �˺��б�ı༭ģʽ
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
	// Ӳ���ذ�ť
	public boolean onKeyDown(int keyCode, KeyEvent event) {  
	    if(keyCode == KeyEvent.KEYCODE_BACK){
	    	on_account_manager_activity_go_back();
			this.finish();
			return true;				
	    }  
	    return super.onKeyDown(keyCode, event);  
	}
	
	// ���ػص�
	@Override
	public void on_go_back() {
		super.on_go_back();
		on_account_manager_activity_go_back();
	}
	
	private void on_account_manager_activity_go_back(){
		// ���ڿ�����ɾ���û�ʱ��ɾ���˵�ǰ����¼���û������� is_logged_in()�᷵��false
		if (!is_logged_in()) {
			if (User.count() > 0) {
				// ��������û�����ѡ�������û��еĵ�һ�����л�֮
				AccountManager.switch_account(User.all().get(0));
				// open main_activity ��ջ�ᱻMindpinBaseActivity�Զ�����
				open_activity(MainActivity.class);
			} else {
				// ���û���û��ˣ���ر������Ѿ��򿪵Ľ��棬�ٴ򿪵�¼����
				restart_to_login();
			}
		}
	}
	
	public void open_login(){
		open_activity(LoginActivity.class);
	}
	
}
