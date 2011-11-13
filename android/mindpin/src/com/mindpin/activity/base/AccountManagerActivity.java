package com.mindpin.activity.base;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.ListView;

import com.mindpin.R;
import com.mindpin.Logic.AccountManager;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.base.utils.BaseUtils;
import com.mindpin.model.database.AccountUserDBHelper;
import com.mindpin.widget.adapter.AccountListAdapter;

public class AccountManagerActivity extends MindpinBaseActivity {
	
	private ListView list_view;
	private AccountListAdapter adapter;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.base_account_manager);
		
		list_view = (ListView)findViewById(R.id.account_list);
		bind_add_account_event();
		fill_list();
		
	}

	// ���� �����˺Ű�ť�¼�
	private void bind_add_account_event() {
		View footer_view = getLayoutInflater().inflate(R.layout.list_account_footer, null);
		list_view.addFooterView(footer_view);
		
		View button = footer_view.findViewById(R.id.add_account);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				open_activity(LoginActivity.class);
			}
		});
	}
	
	// ����˺��б���Ϣ�������б�󶨵���¼�
	private void fill_list() {
		try{
			adapter = new AccountListAdapter(this);
			adapter.add_items(AccountUserDBHelper.all());
			list_view.setAdapter(adapter);
			
			list_view.setOnItemClickListener(new OnItemClickListener() {
				@Override
				public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
					AccountManager.switch_account(adapter.fetch_item(position));
					startActivity(new Intent(AccountManagerActivity.this,MainActivity.class));
					AccountManagerActivity.this.finish();
				}
			});
			
		} catch(Exception e) {
			Log.e("AccountManagerActivity", "fill_list", e);
			BaseUtils.toast("�˺����ݼ��ش���");
		}
	}
	
	// ���� �˺��б�ı༭ģʽ
	public void on_edit_account_button_click(View view){
		Button button = (Button) view;
		
		if(adapter.is_edit_mode()){
			adapter.close_edit_mode();
			button.setText(R.string.account_edit_button);
		}else{
			adapter.open_edit_mode();
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
		try{
			if (!is_logged_in()) {
				if (AccountUserDBHelper.count() > 0) {
					// ��������û�����ѡ�������û��еĵ�һ�����л�֮
					AccountManager.switch_account(AccountUserDBHelper.all().get(0));
					// open main_activity ��ջ�ᱻMindpinBaseActivity�Զ�����
					open_activity(MainActivity.class);
				} else {
					// ���û���û��ˣ���ر������Ѿ��򿪵Ľ��棬�ٴ򿪵�¼����
					restart_to_login();
				}
			}
		} catch(Exception e){
			Log.e("AccountManagerActivity", "on_account_manager_activity_go_back", e);
			BaseUtils.toast("�˺����ݼ��ش���");
			restart_to_login();
		}
	}
	
}
