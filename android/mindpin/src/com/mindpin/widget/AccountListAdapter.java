package com.mindpin.widget;

import java.util.ArrayList;

import com.mindpin.R;
import com.mindpin.Logic.AccountManager;
import com.mindpin.database.User;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

public class AccountListAdapter extends BaseAdapter   {
	private ArrayList<User> users;
	private LayoutInflater mInflater;
	private boolean is_edit_mode = false;

	public AccountListAdapter(Context context){
		super();
		this.users = User.get_users();
		this.mInflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
	}

	@Override
	public int getCount() {
		return users.size();
	}

	@Override
	public Object getItem(int position) {
		return users.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View view = mInflater.inflate(R.layout.account_item, parent, false);
		TextView id_tv = (TextView)view.findViewById(R.id.account_id);
		TextView name_tv = (TextView)view.findViewById(R.id.account_name);
		ImageView img = (ImageView)view.findViewById(R.id.current_account);
		if(is_edit_mode){
			Button delete_bn = (Button)view.findViewById(R.id.account_delete);
			delete_bn.setVisibility(View.VISIBLE);
		}
		final User user = (User)users.get(position);
		if(AccountManager.current_user_id() == user.user_id){
			img.setVisibility(View.VISIBLE);
		}
		id_tv.setText(user.user_id+"");
		name_tv.setText(user.name);
		Button delete_bn = (Button)view.findViewById(R.id.account_delete);
		final int pos = position;
		delete_bn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				AccountManager.remove(user.user_id);
				AccountListAdapter.this.remove_item(pos);
			}
		});
		return view;
	}
	
	public void remove_item(int position){
		users.remove(position);
		this.notifyDataSetChanged();
	}
	
	public void open_edit_mode(){
		is_edit_mode = true;
		this.notifyDataSetChanged();
	}
	
	public void close_edit_mode(){
		is_edit_mode = false;
		this.notifyDataSetChanged();
	}
	
	public boolean is_edit_mode(){
		return is_edit_mode;
	}

}
