package com.mindpin.widget;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.widget.TextView;

import com.mindpin.R;

public class MindpinProgressDialog extends Dialog {
	private String message;

	public MindpinProgressDialog(Context context,String message) {
		super(context,R.style.mindpin_progress_dialog);
		this.message = message;
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.setContentView(R.layout.mindpin_progress_dialog);
		this._set_text();
	}

	public static MindpinProgressDialog show(Context context, String message) {
		MindpinProgressDialog dialog = new MindpinProgressDialog(context,message);
		dialog.show();
		return dialog;
	}
	
	private void _set_text(){
		TextView message_textview = (TextView)findViewById(R.id.mindpin_progress_dialog_message);
		message_textview.setText(this.message);
	}

}
