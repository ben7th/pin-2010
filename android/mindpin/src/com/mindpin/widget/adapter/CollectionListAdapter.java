package com.mindpin.widget.adapter;

import java.util.ArrayList;
import com.mindpin.R;
import com.mindpin.Logic.Http;
import com.mindpin.application.MindpinApplication;
import com.mindpin.base.activity.MindpinBaseActivity;
import com.mindpin.base.task.MindpinAsyncTask;
import com.mindpin.base.utils.BaseUtils;
import com.mindpin.beans.Collection;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

public class CollectionListAdapter extends BaseAdapter {
	private ArrayList<Collection> collections;
	private boolean edit_mode;
	private MindpinBaseActivity activity;

	public CollectionListAdapter(ArrayList<Collection> collections,
			MindpinBaseActivity activity) {
		this.collections = collections;
		this.edit_mode = false;
		this.activity = activity;
	}

	@Override
	public int getCount() {
		return collections.size();
	}

	@Override
	public Object getItem(int position) {
		return collections.get(position);
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		Collection collection = collections.get(position);
		convertView = generate_view_holder(convertView);

		ViewHolder view_holder = (ViewHolder) convertView.getTag();
		fill_with_collection_data(view_holder, collection);
		bind_button_event(position, view_holder, collection);
		return convertView;
	}

	private void bind_button_event(final int position, ViewHolder view_holder,
			Collection collection) {
		if (this.edit_mode) {
			view_holder.edit_collection.setVisibility(View.VISIBLE);
			view_holder.destroy_collection.setVisibility(View.VISIBLE);

			final String collection_id = collection.collection_id + "";
			final String title = collection.title;

			view_holder.edit_collection
					.setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View v) {
							show_change_collection_name_dialog(position,
									collection_id, title);
						}
					});
			view_holder.destroy_collection
					.setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View v) {
							show_destroy_collection_dialog(position,
									collection_id);
						}
					});
		} else {
			view_holder.edit_collection.setVisibility(View.GONE);
			view_holder.destroy_collection.setVisibility(View.GONE);
		}
	}

	public void start_edit_mode() {
		this.edit_mode = true;
		this.notifyDataSetChanged();
	}

	public void end_edit_mode() {
		this.edit_mode = false;
		this.notifyDataSetChanged();
	}

	public boolean is_edit_mode() {
		return this.edit_mode;
	}

	private void fill_with_collection_data(ViewHolder view_holder,
			Collection collection) {
		view_holder.id_tv.setText(collection.collection_id + "");
		view_holder.title_tv.setText(collection.title);
	}

	private View generate_view_holder(View convertView) {
		if (null == convertView) {
			ViewHolder view_holder = new ViewHolder();
			convertView = MindpinApplication.inflate(R.layout.collection_item,
					null);
			view_holder.id_tv = (TextView) convertView
					.findViewById(R.id.collection_id);
			view_holder.title_tv = (TextView) convertView
					.findViewById(R.id.collection_title);
			view_holder.edit_collection = (Button) convertView
					.findViewById(R.id.edit_collection);
			view_holder.destroy_collection = (Button) convertView
					.findViewById(R.id.destroy_collection);
			convertView.setTag(view_holder);
		}
		return convertView;
	}

	private void show_change_collection_name_dialog(final int position,
			final String id, final String old_title) {
		final View view = MindpinApplication.inflate(
				R.layout.change_collection_name_dialog, null);
		EditText ctet = (EditText) view.findViewById(R.id.collection_title_et);
		ctet.setText(old_title);
		AlertDialog.Builder builder = new AlertDialog.Builder(activity);
		builder.setTitle("修改标题");
		builder.setView(view);
		builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				EditText ctet = (EditText) view
						.findViewById(R.id.collection_title_et);
				final String title = ctet.getText().toString();
				if (title == null || "".equals(title)) {
					BaseUtils.toast("请输入标题");
					return;
				}

				new MindpinAsyncTask<String, Void, Boolean>(activity, "正在修改...") {
					@Override
					public Boolean do_in_background(String... params)
							throws Exception {
						String id_str = params[0];
						int id1 = Integer.parseInt(id_str);
						String title = params[1];
						return Http.change_collection_name(id1, title);
					}

					@Override
					public void on_success(Boolean result) {
						if (result) {
							BaseUtils.toast("操作成功");
							change_collection_name(position, title);
						} else {
							BaseUtils.toast("操作失败");
						}
					}
				}.execute(id, title);
			}
		});
		builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
			}
		});
		builder.show();
	}

	private void change_collection_name(int position, String title) {
		Collection collection = collections.get(position);
		collection.title = title;
		this.notifyDataSetChanged();
	}

	private void show_destroy_collection_dialog(final int position,
			final String id) {
		AlertDialog.Builder builder = new AlertDialog.Builder(activity);
		builder.setMessage("确定删除这个收集册吗？");
		builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				new MindpinAsyncTask<String, Void, Boolean>(activity, "正在修改...") {
					@Override
					public Boolean do_in_background(String... params)
							throws Exception {
						int id = Integer.parseInt(params[0]);
						return Http.destroy_collection(id);
					}

					@Override
					public void on_success(Boolean result) {
						if (result) {
							BaseUtils.toast("操作成功");
							remove_collection_item(position);
						} else {
							BaseUtils.toast("操作失败");
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

	private void remove_collection_item(int position) {
		collections.remove(position);
		this.notifyDataSetChanged();
	}

	private class ViewHolder {
		public Button destroy_collection;
		public Button edit_collection;
		public TextView id_tv;
		public TextView title_tv;
	}
}
