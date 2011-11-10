package com.mindpin.widget.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.mindpin.R;

public class HeadBar extends RelativeLayout {
	private TextView title_textview;
	
	public HeadBar(Context context, AttributeSet attrs) {
		super(context, attrs);
		
		//�����Զ���xml������ʹ�ô���� context������ʹ��application_context�����¼�����
		LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View view = inflater.inflate(R.xml.widget_head_bar, this, true);
		
		this.title_textview = (TextView) view.findViewById(R.id.widget_head_bar_title);
		
		//���Զ���������������ֵ
		String title = attrs.getAttributeValue(null, "title");
		set_title(title);
		
	}
	
	public void set_title(String title){
		title_textview.setText(title);
	}
	
	public void set_title(int resid){
		title_textview.setText(resid);
	}

}
