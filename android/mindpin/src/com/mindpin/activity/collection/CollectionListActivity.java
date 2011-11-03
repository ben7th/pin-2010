package com.mindpin.activity.collection;

import java.util.ArrayList;
import java.util.HashMap;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.TextView;
import android.widget.Toast;
import com.mindpin.R;
import com.mindpin.Logic.Http;
import com.mindpin.activity.feed.FeedListActivity;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.base.task.MindpinAsyncTask;
import com.mindpin.cache.CollectionsCache;

public class CollectionListActivity extends MindpinBaseActivity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.collection_list);

		build_new_collection_logic();
		
		build_collection_list(false);
	}

	private void build_new_collection_logic() {
		Button new_collection = (Button) findViewById(R.id.new_collection);
		new_collection.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				show_new_collection_dialog();
			}
		});
	}
	
	private void show_new_collection_dialog() {
		LayoutInflater factory = LayoutInflater
				.from(CollectionListActivity.this);
		final View view = factory.inflate(R.layout.new_collection_dialog, null);
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setTitle("新建收集册");
		builder.setView(view);
		builder.setPositiveButton("创建", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				EditText ctet = (EditText) view
						.findViewById(R.id.collection_title_et);
				String title = ctet.getText().toString();
				if (title == null || "".equals(title)) {
					Toast.makeText(getApplicationContext(), "请输入标题",
							Toast.LENGTH_SHORT).show();
					return;
				}
				create_collection(title);
			}
		});
		builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
			}
		});
		builder.show();
	}
	
	private void build_collection_list(boolean edit_mode) {
		final ArrayList<HashMap<String, Object>> collections = CollectionsCache.get_current_user_collection_list();
		ListView collection_list_lv = (ListView) findViewById(R.id.collection_list);
		
		final CollectionListAdapter sa = new CollectionListAdapter(collections,edit_mode);
		collection_list_lv.setAdapter(sa);
		final Button toggle_list_mode_bn = (Button)findViewById(R.id.toggle_list_mode);
		if(edit_mode){
			toggle_list_mode_bn.setText("完成");
		}else{
			toggle_list_mode_bn.setText("编辑");
		}
		
		toggle_list_mode_bn.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				if(!sa.is_edit_mode()){
					toggle_list_mode_bn.setText("完成");
					sa.start_edit_mode();
				}else{
					toggle_list_mode_bn.setText("编辑");
					sa.end_edit_mode();
				}
			}
		});
		
		collection_list_lv.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				HashMap<String, Object> hash = collections.get(arg2);
				int id = (Integer) hash.get("id");
				String title = (String) hash.get("title");
				Intent intent = new Intent(CollectionListActivity.this,
						FeedListActivity.class);
				intent.putExtra(FeedListActivity.EXTRA_COLLECTION_ID,
						id);
				intent.putExtra(
						FeedListActivity.EXTRA_COLLECTION_TITLE,
						title);
				startActivity(intent);
			}
		});
	}
	
	private void create_collection(String title){
		new MindpinAsyncTask<String,Void,Boolean>(this,"正在创建..."){
			@Override
			public Boolean do_in_background(String... params) throws Exception {
				String title1 = params[0];
				return Http.create_collection(title1);
			}

			@Override
			public void on_success(Boolean result) {
				if (result) {
					build_collection_list(false);
					Toast.makeText(getApplicationContext(), "操作成功",
							Toast.LENGTH_SHORT).show();
				} else {
					Toast.makeText(getApplicationContext(), "创建失败",
							Toast.LENGTH_SHORT).show();
				}
			}
		}.execute(title);
	}
	
	class CollectionListAdapter extends SimpleAdapter{
		private boolean edit_mode = false;

		public CollectionListAdapter(ArrayList<HashMap<String, Object>> collections,boolean edit_mode) {
			super(CollectionListActivity.this,
					collections, R.layout.collection_item, new String[] { "id",
							"title" }, new int[] { R.id.collection_id,
							R.id.collection_title });
			this.edit_mode = edit_mode;
		}
		
		public void start_edit_mode(){
			this.edit_mode = true;
			this.notifyDataSetChanged();
		}
		
		public void end_edit_mode(){
			this.edit_mode = false;
			this.notifyDataSetChanged();
		}
		
		public boolean is_edit_mode(){
			return this.edit_mode;
		}
		
		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			View view = super.getView(position, convertView, parent);
			
			Button edit_collection = (Button)view.findViewById(R.id.edit_collection);
			Button destroy_collection = (Button)view.findViewById(R.id.destroy_collection);
			if(this.edit_mode){
				edit_collection.setVisibility(View.VISIBLE);
				destroy_collection.setVisibility(View.VISIBLE);
				TextView title_view = (TextView)view.findViewById(R.id.collection_title);
				final String title = (String) title_view.getText();
				TextView id_view = (TextView)view.findViewById(R.id.collection_id);
				final String id = (String) id_view.getText();
				edit_collection.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View v) {
						show_change_collection_name_dialog(id,title);
					}
				});
				destroy_collection.setOnClickListener(new OnClickListener() {
					@Override
					public void onClick(View v) {
						show_destroy_collection_dialog(id);
					}
				});
			}else{
				edit_collection.setVisibility(View.GONE);
				destroy_collection.setVisibility(View.GONE);
			}
			return view;
		}
		
	}
	
	private void show_change_collection_name_dialog(final String id,final String old_title) {
		LayoutInflater factory = LayoutInflater
				.from(this);
		final View view = factory.inflate(R.layout.change_collection_name_dialog, null);
		EditText ctet = (EditText) view
				.findViewById(R.id.collection_title_et);
		ctet.setText(old_title);
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setTitle("修改标题");
		builder.setView(view);
		builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				EditText ctet = (EditText) view
						.findViewById(R.id.collection_title_et);
				String title = ctet.getText().toString();
				if (title == null || "".equals(title)) {
					Toast.makeText(getApplicationContext(), "请输入标题",
							Toast.LENGTH_SHORT).show();
					return;
				}
				new MindpinAsyncTask<String,Void,Boolean>(CollectionListActivity.this,"正在修改..."){
					@Override
					public Boolean do_in_background(String... params) throws Exception {
						String id_str = params[0];
						int id1 = Integer.parseInt(id_str);
						String title = params[1];
						return Http.change_collection_name(id1,title);
					}

					@Override
					public void on_success(Boolean result) {
						if (result) {
							Toast.makeText(getApplicationContext(),"操作成功",
									Toast.LENGTH_SHORT).show();
							build_collection_list(true);
						} else {
							Toast.makeText(getApplicationContext(),"操作失败",
									Toast.LENGTH_SHORT).show();
						}
					}
				}.execute(id,title);
			}
		});
		builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
			}
		});
		builder.show();
	}
	
	private void show_destroy_collection_dialog(final String id) {
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setMessage("确定删除这个收集册吗？");
		builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				new MindpinAsyncTask<String,Void,Boolean>(CollectionListActivity.this,"正在修改..."){
					@Override
					public Boolean do_in_background(String... params) throws Exception {
						int id = Integer.parseInt(params[0]);
						return Http.destroy_collection(id);
					}

					@Override
					public void on_success(Boolean result) {
						if (result) {
							Toast.makeText(getApplicationContext(),"操作成功",
									Toast.LENGTH_SHORT).show();
							build_collection_list(true);
						} else {
							Toast.makeText(getApplicationContext(),"操作失败",
									Toast.LENGTH_SHORT).show();
						}
					}
				}.execute(id);
			}
		});
		builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
			}
		});
		builder.show();
	}
}
