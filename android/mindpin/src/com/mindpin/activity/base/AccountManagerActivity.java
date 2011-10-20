package com.mindpin.activity.base;

import com.mindpin.R;
import com.mindpin.widget.AccountListAdapter;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ListView;

public class AccountManagerActivity extends Activity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.account_manager);
		
		ListView lv = (ListView)findViewById(R.id.account_list);
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
		lv.setAdapter(new AccountListAdapter(this));
	}
}
