package com.mindpin.widget.view;

import java.util.List;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.mindpin.R;
import com.mindpin.base.adapter.MindpinBaseAdapter;
import com.mindpin.base.task.MindpinAsyncTask;
import com.mindpin.base.utils.BaseUtils;

abstract public class ListMoreButton<M> extends LinearLayout {
	private MindpinBaseAdapter<M> adapter;
	
	private TextView info_textview;
	private ProgressBar loading_icon;
	private View list_more_button;

	public ListMoreButton(MindpinBaseAdapter<M> adapter) {
		super(adapter.activity);
		
		this.adapter = adapter;
		
		//�����Զ���xml������ʹ�ô���� context������ʹ��application_context�����¼�����
		LayoutInflater inflater = (LayoutInflater) adapter.activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View view = inflater.inflate(R.layout.list_more_button, this, true);
		
		this.info_textview = (TextView)    view.findViewById(R.id.list_more_button_info);
		this.loading_icon  = (ProgressBar) view.findViewById(R.id.list_more_button_loading);
		
		this.list_more_button = view.findViewById(R.id.list_more_button);
		this.list_more_button.setClickable(true);
		
		this.bind_on_click_event();
	}

	public void start_loading(){
		info_textview.setText(R.string.now_loading);
		loading_icon.setVisibility(View.VISIBLE);
	}
	
	public void stop_loading(){
		info_textview.setText("�鿴����");
		loading_icon.setVisibility(View.GONE);
	}
	
	private void bind_on_click_event(){
		this.list_more_button.setOnClickListener(new OnClickListener(){

			@Override
			public void onClick(View v) {
				new MindpinAsyncTask<String, Void, List<M>>() {
					@Override
					public void on_start() {
						start_loading();
					};
					
					public List<M> do_in_background(String... params) throws Exception {
						return load();
					}

					@Override
					public void on_success(List<M> items) {
						adapter.add_items(items);
					}
					
					public void on_final() {
						stop_loading();
					};
					
					public boolean on_unknown_exception() {
						BaseUtils.toast("���ݶ�ȡʧ��");
						return false;
					};
				}.execute();
			}
			
		});
	}
	
	abstract public List<M> load() throws Exception;
}
