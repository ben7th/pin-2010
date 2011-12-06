package com.mindpin.activity.sendfeed;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import com.mapabc.mapapi.GeoPoint;
import com.mapabc.mapapi.MapActivity;
import com.mapabc.mapapi.MapController;
import com.mapabc.mapapi.MapView;
import com.mapabc.mapapi.MyLocationOverlay;
import com.mindpin.R;

public class MyLocationActivity extends MapActivity {
	public static final int FIRST_LOCATION=110;
	private MapView map_view;
	private MapController map_controller;
	private MyLocationOverlay location_overlay;
	private Handler handler = new Handler() {
		public void handleMessage(Message msg) {
			if (msg.what == FIRST_LOCATION) {
				map_controller.animateTo(location_overlay.getMyLocation());
			}
		}
    };

	@Override
	protected void onCreate(Bundle arg0) {
    	this.setMapMode(MAP_MODE_VECTOR);//设置地图为矢量模式
		super.onCreate(arg0);
		setContentView(R.layout.my_location);
		
		map_view = (MapView) findViewById(R.id.mapView);
		map_controller = map_view.getController();
		
		map_view.setBuiltInZoomControls(true);  // 增加地图缩放的两个按钮
		
		location_overlay = new MyLocationOverlay(this, map_view);
		map_view.getOverlays().add(location_overlay);
		//实现初次定位使定位结果居中显示
		location_overlay.runOnFirstFix(new Runnable() {
			public void run() {
            	handler.sendMessage(Message.obtain(handler, FIRST_LOCATION));
            }
        });
	}
	
    @Override
	protected void onPause() {
    	location_overlay.disableMyLocation();
		super.onPause();
	}

	@Override
	protected void onResume() {
		location_overlay.enableMyLocation();
		super.onResume();
	}
}
