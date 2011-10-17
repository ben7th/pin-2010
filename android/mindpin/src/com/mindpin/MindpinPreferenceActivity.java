package com.mindpin;

import android.os.Bundle;
import android.preference.PreferenceActivity;

public class MindpinPreferenceActivity extends PreferenceActivity {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		addPreferencesFromResource(R.xml.preferences);
	}
}
