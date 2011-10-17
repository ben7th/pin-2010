package com.mindpin;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.mindpin.Logic.Http;
import com.mindpin.cache.CollectionsCache;
import com.mindpin.runnable.MindpinHandler;
import com.mindpin.runnable.MindpinRunnable;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
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
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.Toast;

public class SelectCollectionListActivity extends Activity {
	public static final String EXTRA_NAME_KIND = "kind";
	public static final String EXTRA_VALUE_SELECT_FOR_SEND = "select_for_send";
	public static final String EXTRA_VALUE_SELECT_FOR_RESULT = "select_for_result";
	public static final String EXTRA_NAME_SELECT_COLLECTION_IDS = "select_collection_ids";
	public static final String EXTRA_NAME_SEND_TSINA = "send_tsina";
	
	public static final int MESSAGE_INTENT_CONNECTION_FAIL = 0;
	public static final int MESSAGE_CREATE_COLLECTION_SUCCESS = 1;
	public static final int MESSAGE_CREATE_COLLECTION_FAIL = 2;
	public static final int MESSAGE_AUTH_FAIL = 3;
	
	private List<HashMap<String, Object>> collections;
	private ArrayList<Integer> select_collection_ids;
	private Button send_bn;
	private Button submit_bn;
	private Button cancel_bn;
	private CheckBox send_tsina_cb;
	private ListView collection_list_lv;
	private Button new_collection_bn;
	private ProgressDialog progress_dialog;
	private MindpinHandler mhandler = new MindpinHandler(this){
		public boolean mindpin_handle_message(android.os.Message msg) {
			progress_dialog.dismiss();
			switch (msg.what) {
			case MESSAGE_CREATE_COLLECTION_SUCCESS:
				collections = CollectionsCache.get_collection_list();
				HashMap<String, Object> c = collections
						.get(collections.size() - 1);
				Integer id = (Integer) c.get("id");
				if (select_collection_ids.indexOf(id) == -1) {
					select_collection_ids.add(id);
				}
				build_collection_list_data();
				collection_list_lv
						.setSelection(collection_list_lv.getCount() - 1);
				Toast.makeText(getApplicationContext(), "操作成功",
						Toast.LENGTH_SHORT).show();
				return true;
			case MESSAGE_CREATE_COLLECTION_FAIL:
				Toast.makeText(getApplicationContext(), "创建失败",
						Toast.LENGTH_SHORT).show();
				return true;
			}
			return false;
		}
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.select_collection_list);
		send_tsina_cb = (CheckBox)findViewById(R.id.send_tsina_cb);
		boolean send_tsina = getIntent().getBooleanExtra(EXTRA_NAME_SEND_TSINA,false);
		send_tsina_cb.setChecked(send_tsina);
		
		select_collection_ids = new ArrayList<Integer>();
		String kind = getIntent().getStringExtra(EXTRA_NAME_KIND);
		if(kind.equals(EXTRA_VALUE_SELECT_FOR_RESULT)){
			init_select_for_result();
		}else if(kind.equals(EXTRA_VALUE_SELECT_FOR_SEND)){
			init_select_for_send();
		}
		
		build_collection_list();
		new_collection_logic();
	}

	private void new_collection_logic() {
		new_collection_bn = (Button) findViewById(R.id.new_collection_bn);
		new_collection_bn.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				show_new_collection_dialog();
			}
		});
	}
	
	private void show_new_collection_dialog() {
		LayoutInflater factory = LayoutInflater
				.from(SelectCollectionListActivity.this);
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
				progress_dialog = ProgressDialog.show(
						SelectCollectionListActivity.this, "", "正在创建...");
				Thread thread = new Thread(new CreateCollectionRunnable(title));
				thread.setDaemon(true);
				thread.start();		
			}
		});
		builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
			}
		});
		builder.show();
	}
	
	private void build_collection_list() {
		build_collection_list_logic();
		collections = CollectionsCache.get_collection_list();
		build_collection_list_data();
	}

	private void build_collection_list_data() {
		SimpleAdapter sa = new MySimpleAdapter(SelectCollectionListActivity.this,
				collections, R.layout.select_collection_item, new String[] { "id",
						"title" }, new int[] { R.id.collection_id,
						R.id.collection_title });
		collection_list_lv.setAdapter(sa);
	}

	private void build_collection_list_logic() {
		collection_list_lv = (ListView) findViewById(R.id.select_collection_list);
		collection_list_lv.setOnItemClickListener(new OnItemClickListener() {
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				CheckBox cb = (CheckBox)arg1.findViewById(R.id.check_box);
				HashMap<String, Object> object = collections.get(arg2);
				Integer id = (Integer)object.get("id");
				if(cb.isChecked()){
					cb.setChecked(false);
					arg1.setBackgroundColor(android.R.color.black);
					select_collection_ids.remove(id);
				}else{
					cb.setChecked(true);
					arg1.setBackgroundColor(R.color.darkgray);
					select_collection_ids.add(id);
				}
			}
		});
	}

	private void init_select_for_send() {
		cancel_bn = (Button)findViewById(R.id.cancel_bn);
		cancel_bn.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Intent intent = new Intent();
				setResult(Activity.RESULT_CANCELED,intent);
				finish();
			}
		});
		
		send_bn = (Button) findViewById(R.id.send_bn);
		send_bn.setVisibility(View.VISIBLE);
		send_bn.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				if(select_collection_ids!=null && select_collection_ids.size()!=0){
					Intent intent = new Intent();
					intent.putIntegerArrayListExtra(EXTRA_NAME_SELECT_COLLECTION_IDS,
							select_collection_ids);
					if(send_tsina_cb.isChecked()){
						intent.putExtra(EXTRA_NAME_SEND_TSINA,
								true);
					}else{
						intent.putExtra(EXTRA_NAME_SEND_TSINA,
								false);
					}
					setResult(Activity.RESULT_OK,intent);
					finish();
				}else{
					Toast.makeText(getApplicationContext(),
							"至少选择一个收集册", Toast.LENGTH_SHORT)
							.show();
				}
			}
		});
		
		
	}

	private void init_select_for_result() {
		ArrayList<Integer> ids = getIntent().getIntegerArrayListExtra(EXTRA_NAME_SELECT_COLLECTION_IDS);
		if(ids !=null){
			select_collection_ids = ids;
		}
		
		submit_bn = (Button) findViewById(R.id.submit_bn);
		submit_bn.setVisibility(View.VISIBLE);
		submit_bn.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Intent intent = new Intent();
				intent.putIntegerArrayListExtra(EXTRA_NAME_SELECT_COLLECTION_IDS,
						select_collection_ids);
				if(send_tsina_cb.isChecked()){
					intent.putExtra(EXTRA_NAME_SEND_TSINA,
							true);
				}else{
					intent.putExtra(EXTRA_NAME_SEND_TSINA,
							false);
				}
				setResult(Activity.RESULT_OK,intent);
				finish();
			}
		});
		
		cancel_bn = (Button)findViewById(R.id.cancel_bn);
		cancel_bn.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Intent intent = new Intent();
				setResult(Activity.RESULT_CANCELED,intent);
				finish();
			}
		});
	}
	
	public class MySimpleAdapter extends SimpleAdapter {
		public MySimpleAdapter(Context context,
				List<? extends Map<String, ?>> data, int resource,
				String[] from, int[] to) {
			super(context, data, resource, from, to);
		}
		
		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			View view = super.getView(position, convertView, parent);
			HashMap<String, Object> object = collections.get(position);
			Integer id = (Integer)object.get("id");
			if(select_collection_ids !=null && select_collection_ids.indexOf(id) != -1){
				CheckBox cb = (CheckBox)view.findViewById(R.id.check_box);
				cb.setChecked(true);
				view.setBackgroundColor(R.color.darkgray);
			}
			return view;
		}
	}
	
	
	public class CreateCollectionRunnable extends MindpinRunnable {
		private String title;
		
		public CreateCollectionRunnable(String title) {
			super(mhandler);
			this.title = title;
		}

		public void mindpin_run() throws Exception {
			boolean success = Http.create_collection(title);
			if (success) {
				collections = CollectionsCache.get_collection_list();
				mhandler.sendEmptyMessage(MESSAGE_CREATE_COLLECTION_SUCCESS);
			} else {
				mhandler.sendEmptyMessage(MESSAGE_CREATE_COLLECTION_FAIL);
			}
		}
	}
}
