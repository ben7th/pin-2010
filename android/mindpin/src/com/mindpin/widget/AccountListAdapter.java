package com.mindpin.widget;

import java.util.ArrayList;

import com.mindpin.R;
import com.mindpin.database.User;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class AccountListAdapter extends BaseAdapter   {
	private ArrayList<User> users;
	private LayoutInflater mInflater;

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
		User user = (User)users.get(position);
		id_tv.setText(user.id+"");
		name_tv.setText(user.name);
		return view;
	}

}
