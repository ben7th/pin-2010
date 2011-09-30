package com.mindpin;

import java.util.ArrayList;
import com.mindpin.R;
import com.mindpin.Logic.AccountManager;
import com.mindpin.Logic.AccountManager.AuthenticateException;
import com.mindpin.Logic.CameraLogic;
import com.mindpin.Logic.FeedDraftManager;
import com.mindpin.Logic.Http;
import com.mindpin.Logic.Http.IntentException;
import com.mindpin.database.FeedDraft;
import com.mindpin.utils.BaseUtils;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Resources;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.Parcelable;
import android.provider.MediaStore;
import android.util.TypedValue;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.RadioGroup.OnCheckedChangeListener;
import android.widget.RelativeLayout;
import android.widget.Toast;

public class NewFeedActivity extends Activity {
	public static final int REQUEST_SHOW_IMAGE_CAPTURE = 1;
	public static final int REQUEST_SHOW_IMAGE_ALBUM = 2;
	protected static final int REQUEST_SELECT_COLLECTIONS = 3;
	protected static final int REQUEST_SELECT_COLLECTIONS_AND_SEND = 4;
	
	protected static final int MESSAGE_LOGGED = 1;
	protected static final int MESSAGE_UNLOGGED = 2;
	protected static final int MESSAGE_INTENT_FAIL = 3;
	public static final int MESSAGE_AUTH_FAIL = 4;
	public static final int MESSAGE_SENDING_FEED = 5;
	public static final int MESSAGE_SEND_FEED_SUCCESS = 6;
	public static final int MESSAGE_SAVE_FEED_DRAFT = 7;
	LinearLayout feed_captures;
	RelativeLayout feed_captures_parent;
	private ArrayList<String> capture_paths = new ArrayList<String>();
	
	private EditText feed_title_et;
	private EditText feed_content_et;
	private String feed_title;
	private String feed_content;
	private ArrayList<Integer> select_collection_ids;
	
	private ImageButton capture_bn;
	private Button send_bn;
	private ImageButton album_bn;
	private Button select_collections_bn;
	private boolean send_tsina = false;
	private int feed_draft_id = 0;
	
	private ProgressDialog progress_dialog;
	private Handler mhandler = new Handler(){
		public void handleMessage(android.os.Message msg) {
			switch (msg.what) {
			case MESSAGE_LOGGED:
				progress_dialog.dismiss();
				break;
			case MESSAGE_UNLOGGED:
				progress_dialog.dismiss();
				alert("登录失败，请重新登录");
				break;
			case MESSAGE_INTENT_FAIL:
				progress_dialog.dismiss();
				alert("网络不可用");
				break;
			case MESSAGE_AUTH_FAIL:
				progress_dialog.dismiss();
				Toast.makeText(getApplicationContext(), R.string.auth_fail_tip,
						Toast.LENGTH_SHORT).show();
				startActivity(new Intent(NewFeedActivity.this,LoginActivity.class));
				NewFeedActivity.this.finish();
				break;
			case MESSAGE_SENDING_FEED:
				progress_dialog.setProgress(msg.arg1);
				break;
			case MESSAGE_SEND_FEED_SUCCESS:
				progress_dialog.dismiss();
				Toast.makeText(getApplicationContext(), "发送成功",
						Toast.LENGTH_SHORT).show();
				NewFeedActivity.this.finish();
				break;
			case MESSAGE_SAVE_FEED_DRAFT:
				progress_dialog.dismiss();
				Toast.makeText(getApplicationContext(), "网络不可用，已保存草稿",
						Toast.LENGTH_SHORT).show();
				NewFeedActivity.this.finish();
				break;
			}
		};
	};
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.new_feed);
		find_views();
		set_listener();
		process_extra();
		process_share();
		process_feed_draft();
	}
	
	private void process_feed_draft() {
		if(FeedDraftManager.has_feed_draft(getApplicationContext())){
			show_feed_draft_list_dialog();
		}
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(resultCode != Activity.RESULT_OK){
			return;
		}
		switch (requestCode) {
		case CameraLogic.REQUEST_CAPTURE:
			add_image_capture_to_feed_captures();
			break;
		case REQUEST_SHOW_IMAGE_ALBUM:
			Uri uri = data.getData();
			String path = get_absolute_imagePath(uri);
			add_image_to_feed_captures(path);
			break;
		case REQUEST_SELECT_COLLECTIONS:
			selected_collections(data);
			break;
		case REQUEST_SELECT_COLLECTIONS_AND_SEND:
			selected_collections_and_send(data);
			break;
		}
		super.onActivityResult(requestCode, resultCode, data);
	}
	
	
	@Override  
	public boolean onKeyDown(int keyCode, KeyEvent event) {  
	    if(keyCode == KeyEvent.KEYCODE_BACK){
			feed_title = feed_title_et.getText().toString();
			feed_content = feed_content_et.getText().toString();
			boolean is_blank = (
					("".equals(feed_title)) &&
					"".equals(feed_content) &&
					(capture_paths.size() == 0) &&
					(select_collection_ids == null || select_collection_ids.size() == 0)
					);
			if(feed_draft_id!=0){
				boolean has_change = FeedDraftManager.has_change(getApplicationContext(),
						feed_draft_id,feed_title,feed_content,capture_paths,select_collection_ids);
				if(!is_blank && has_change){
					save_feed_draft_dialog();
					return true;				
				}
			}else{
				if(!is_blank){
					save_feed_draft_dialog();
					return true;				
				}
			}
	    }  
	    return super.onKeyDown(keyCode, event);  
	} 
	
	private void save_feed_draft_dialog() {
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setMessage("主题尚未发送，是否保存？");
		builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				if(feed_draft_id != 0){
					FeedDraftManager.update_feed_draft(NewFeedActivity.this,feed_draft_id, 
							feed_title,feed_content, capture_paths, select_collection_ids);
				}else{
					FeedDraftManager.save_feed_draft(NewFeedActivity.this, 
							feed_title,feed_content, capture_paths, select_collection_ids);
				}
				NewFeedActivity.this.finish();
			}
		});
		builder.setNegativeButton("取消",new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				NewFeedActivity.this.finish();
			}
		});
		
		builder.show();
		return;
	}

	private void selected_collections_and_send(Intent data) {
		ArrayList<Integer> ids = data.getIntegerArrayListExtra(SelectCollectionListActivity.EXTRA_NAME_SELECT_COLLECTION_IDS);
		send_tsina = data.getExtras().getBoolean(SelectCollectionListActivity.EXTRA_NAME_SEND_TSINA);
		if(ids!=null && ids.size()!=0){
			select_collections_bn.setText("选择了"+ ids.size() +"收集册");
			select_collection_ids = ids;
			send_feed();
		}
	}
	
	private void send_feed(){
		progress_dialog = new ProgressDialog(this);
		progress_dialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
		progress_dialog.setMessage("正在发送...");
		progress_dialog.setProgress(1);
		progress_dialog.show();
		
		Thread thread = new Thread(new SendFeedRunnable());
		thread.setDaemon(true);
		thread.start();
	}

	private void selected_collections(Intent data) {
		ArrayList<Integer> ids = data.getIntegerArrayListExtra(SelectCollectionListActivity.EXTRA_NAME_SELECT_COLLECTION_IDS);
		send_tsina = data.getExtras().getBoolean(SelectCollectionListActivity.EXTRA_NAME_SEND_TSINA);
		if(ids!=null && ids.size()!=0){
			select_collections_bn.setText("选择了"+ ids.size() +"收集册");
			select_collection_ids = ids;
		}else{
			select_collections_bn.setText(R.string.feed_select_collections);
			select_collection_ids = null;
		}
	}

	private void set_listener() {
		capture_bn = (ImageButton)findViewById(R.id.capture_bn);
		capture_bn.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				CameraLogic.call_sysotem_camera(NewFeedActivity.this);
			}
		});
		send_bn = (Button) findViewById(R.id.send_bn);
		send_bn.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {

				feed_title = feed_title_et.getText().toString();
				feed_content = feed_content_et.getText().toString();
				
				if(select_collection_ids == null){
					Intent intent = new Intent(NewFeedActivity.this,SelectCollectionListActivity.class);
					intent.putExtra(SelectCollectionListActivity.EXTRA_NAME_KIND, 
							SelectCollectionListActivity.EXTRA_VALUE_SELECT_FOR_SEND);
					startActivityForResult(intent,REQUEST_SELECT_COLLECTIONS_AND_SEND);
				}else{
					send_feed();
				}
			}
		});
		
		album_bn = (ImageButton) findViewById(R.id.album_bn);
		album_bn.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Uri uri = MediaStore.Images.Media.INTERNAL_CONTENT_URI;
				Intent intent = new Intent("android.intent.action.PICK",
						uri);
				startActivityForResult(intent, REQUEST_SHOW_IMAGE_ALBUM);
			}
		});
		
		select_collections_bn = (Button) findViewById(R.id.select_collections_bn);
		select_collections_bn.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Intent intent = new Intent(NewFeedActivity.this,SelectCollectionListActivity.class);
				intent.putExtra(SelectCollectionListActivity.EXTRA_NAME_KIND, 
						SelectCollectionListActivity.EXTRA_VALUE_SELECT_FOR_RESULT);
				if(select_collection_ids != null && select_collection_ids.size() != 0){
					intent.putIntegerArrayListExtra(SelectCollectionListActivity.EXTRA_NAME_SELECT_COLLECTION_IDS, 
							select_collection_ids);
				}
				startActivityForResult(intent,REQUEST_SELECT_COLLECTIONS);
			}
		});
		
	}
	
	private void find_views() {
		feed_captures = (LinearLayout)findViewById(R.id.feed_captures);
		feed_captures_parent = (RelativeLayout)findViewById(R.id.feed_captures_parent);
		feed_title_et = (EditText) findViewById(R.id.feed_title_et);
		feed_content_et = (EditText) findViewById(R.id.feed_content_et);
		
		feed_captures_parent.setVisibility(View.GONE);
	}
	
	private void process_extra() {
		Intent it = getIntent();
		boolean has_image_capture = it.
				getBooleanExtra(CameraLogic.HAS_IMAGE_CAPTURE, false);
		if(has_image_capture){
			add_image_capture_to_feed_captures();
		}
	}
	
	private void process_share(){
		boolean has_share = false;
		Intent it = getIntent();
		if (Intent.ACTION_SEND.equals(it.getAction())) {
			Bundle extras = it.getExtras();
			has_share = true;
			if (extras.containsKey("android.intent.extra.STREAM")) {
				Uri uri = (Uri) extras.get("android.intent.extra.STREAM");
				String path = get_absolute_imagePath(uri);
				add_image_to_feed_captures(path);
			}
		}
		
		if (Intent.ACTION_SEND_MULTIPLE.equals(it.getAction())) {
			has_share = true;
			ArrayList<Parcelable> uris = it.getParcelableArrayListExtra(Intent.EXTRA_STREAM);
			for (Parcelable parcelable : uris) {
				Uri uri = (Uri)parcelable;
				String path = get_absolute_imagePath(uri);
				add_image_to_feed_captures(path);
			}
		}
		
		if(has_share){
			progress_dialog = ProgressDialog.show(NewFeedActivity.this, "",
					"正在登录...");
			LoginRunnable lr = new LoginRunnable();
			Thread thread = new Thread(lr);
			thread.setDaemon(true);
			thread.start();
		}
	}
	
	private void add_image_capture_to_feed_captures(){
		String path = CameraLogic.image_capture_temp_path.getPath();
		add_image_to_feed_captures(path);
	}
	
	private void add_image_to_feed_captures(String file_path){
		feed_captures_parent.setVisibility(View.VISIBLE);
		capture_paths.add(file_path);
		BitmapFactory.Options options=new BitmapFactory.Options();
		options.inSampleSize = 8;
		Bitmap b = BitmapFactory.decodeFile(file_path, options);
		
		ImageView img = new ImageView(this);
		img.setAdjustViewBounds(true);
		img.setScaleType(ScaleType.CENTER_CROP);
		LayoutParams lp = new LayoutParams(BaseUtils.get_px_by_dip(this,48),
				BaseUtils.get_px_by_dip(this,48));
		lp.topMargin = BaseUtils.get_px_by_dip(this,5);
		lp.leftMargin = BaseUtils.get_px_by_dip(this,4);
		lp.bottomMargin = BaseUtils.get_px_by_dip(this,4);
		img.setLayoutParams(lp);
		img.setImageBitmap(b);
		img.setClickable(true);
		img.setTag(file_path);
		img.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				show_image_dialog((String)v.getTag());
			}
		});
		feed_captures.addView(img);
	}

	private String get_absolute_imagePath(Uri uri) 
	   {
	       String [] proj={MediaStore.Images.Media.DATA};
	       Cursor cursor = managedQuery( uri,proj,        
	                       null,null,null); 
	       int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
	       cursor.moveToFirst();
	       return cursor.getString(column_index);
	   }
	
	private void alert(String content){
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setMessage(content);
		builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				NewFeedActivity.this.finish();
			}
		});
		builder.show();
	}
	
	private void show_feed_draft_list_dialog() {
		LayoutInflater factory = LayoutInflater
				.from(this);
		final View view = factory.inflate(R.layout.feed_draft_list_dialog, null);
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setTitle("打开草稿");
		builder.setView(view);
		builder.setPositiveButton("打开", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				Integer id = (Integer)view.getTag();
				if(id == null) return;
				open_feed_draft(id);
			}
		});
		builder.setNeutralButton("删除", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				Integer id = (Integer)view.getTag();
				if(id == null) return;
				
				FeedDraft.destroy(getApplicationContext(), id);
			}
		});
		builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
			}
		});
		final AlertDialog dialog = builder.create();
		
		RadioGroup feed_drafts_rg = (RadioGroup)view.findViewById(R.id.feed_drafts_rg);
		ArrayList<FeedDraft> feed_drafts = FeedDraftManager.get_feed_drafts(getApplicationContext());
		for (FeedDraft feedDraft : feed_drafts) {
			RadioButton rb = new RadioButton(view.getContext());
			String title = feedDraft.title;
			if(title == null || "".equals(title)) title = "无标题";
			String time_str = BaseUtils.date_string(feedDraft.time);
			title = title + "(" + time_str +")";
			rb.setTag(feedDraft.id);
			rb.setText(title);
			feed_drafts_rg.addView(rb);
		}
		feed_drafts_rg.setOnCheckedChangeListener(new OnCheckedChangeListener() {
			public void onCheckedChanged(RadioGroup group, int checkedId) {
				RadioButton rb = (RadioButton)view.findViewById(checkedId);
				Integer id = (Integer)rb.getTag();
				view.setTag(id);
				dialog.getButton(AlertDialog.BUTTON_POSITIVE).setEnabled(true);
				dialog.getButton(AlertDialog.BUTTON_NEUTRAL).setEnabled(true);				
			}
		});
		dialog.show();
		dialog.getButton(AlertDialog.BUTTON_POSITIVE).setEnabled(false);
		dialog.getButton(AlertDialog.BUTTON_NEUTRAL).setEnabled(false);
	}
	
	private void open_feed_draft(Integer id) {
		feed_draft_id = id;
		FeedDraft fd = FeedDraft.find(getApplicationContext(), id);
		if(fd == null)return;
		
		feed_title_et.setText(fd.title);
		feed_content_et.setText(fd.content);
		
		ArrayList<String> paths = BaseUtils.string_to_string_list(fd.image_paths);
		for (String path : paths) {
			add_image_to_feed_captures(path);
		}
		
		ArrayList<Integer> ids = BaseUtils.string_to_integer_list(fd.select_collection_ids);
		if(ids!=null && ids.size()!=0){
			select_collections_bn.setText("选择了"+ ids.size() +"收集册");
			select_collection_ids = ids;
		}
	}
	
	private void show_image_dialog(String image_path){
		LayoutInflater factory = LayoutInflater
				.from(this);
		final View view = factory.inflate(R.layout.show_image_dialog, null);
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		ImageView iv = (ImageView)view.findViewById(R.id.image_dialog_image_iv);
		Bitmap b = BitmapFactory.decodeFile(image_path);
		iv.setImageBitmap(b);
		builder.setTitle("查看图片");
		builder.setView(view);
		final String path = image_path+"";
		builder.setPositiveButton("移除", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				int index = capture_paths.indexOf(path);
				ImageView image = (ImageView) feed_captures.getChildAt(index);
				feed_captures.removeView(image);
				capture_paths.remove(path);
				if(capture_paths.size() == 0){
					feed_captures_parent.setVisibility(View.GONE);
				}
			}
		});
		builder.setNeutralButton("查看", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				Intent intent = new Intent(NewFeedActivity.this,showImageCaptureActivity.class);
				intent.putExtra(showImageCaptureActivity.EXTRA_NAME_IMAGE_CAPTURE_PATH, path);
				startActivityForResult(intent,REQUEST_SHOW_IMAGE_CAPTURE);
			}
		});
		builder.setNegativeButton("返回", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
			}
		});
		builder.show();
	}
	
	class LoginRunnable implements Runnable{
		public void run() {
			String email = AccountManager.get_email(NewFeedActivity.this);
			String password = AccountManager.get_password(NewFeedActivity.this);
			try {
				if (!"".equals(email) && !"".equals(password)
						&& AccountManager.user_authenticate(email, password)) {
					// 显示内容
					Message msg = mhandler.obtainMessage();
					msg.what = MESSAGE_LOGGED;
					mhandler.sendMessage(msg);
				} else {
					// 显示登录框
					Message msg = mhandler.obtainMessage();
					msg.what = MESSAGE_UNLOGGED;
					mhandler.sendMessage(msg);
				}
			} catch (IntentException e) {
				Message msg = mhandler.obtainMessage();
				msg.what = MESSAGE_INTENT_FAIL;
				mhandler.sendMessage(msg);
				e.printStackTrace();
			}
		}
	}
	
	public class SendFeedRunnable implements Runnable{
		public void run() {
			int request_count = capture_paths.size()+1;
			int step = 100/request_count;
			ArrayList<String> photo_names = new ArrayList<String>();
			try {
				for (int i = 0; i < capture_paths.size(); i++) {
					String capture_path = capture_paths.get(i);
					photo_names.add(Http.upload_photo(capture_path));
					int count = step*(i+1);
					Message msg = mhandler.obtainMessage(MESSAGE_SENDING_FEED,count,0);
					mhandler.sendMessage(msg);
				}
				Http.send_feed(feed_title, feed_content, photo_names, select_collection_ids,send_tsina);
				if(feed_draft_id!=0){
					FeedDraft.destroy(getApplicationContext(), feed_draft_id);
					feed_draft_id=0;
				}
				mhandler.sendEmptyMessage(MESSAGE_SEND_FEED_SUCCESS);
			} catch (IntentException e) {
				if(feed_draft_id != 0){
					FeedDraftManager.update_feed_draft(NewFeedActivity.this,feed_draft_id, 
							feed_title,feed_content, capture_paths, select_collection_ids);
				}else{
					FeedDraftManager.save_feed_draft(NewFeedActivity.this, 
							feed_title,feed_content, capture_paths, select_collection_ids);
				}
				mhandler.sendEmptyMessage(MESSAGE_SAVE_FEED_DRAFT);
			} catch (AuthenticateException e) {
				mhandler.sendEmptyMessage(MESSAGE_AUTH_FAIL);
			}
		}
	};
	
}
