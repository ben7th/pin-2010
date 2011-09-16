package com.mindpin.thread;

import com.mindpin.Logic.AccountManager;
import com.mindpin.Logic.FeedHoldManager;
import com.mindpin.Logic.Http.IntentException;
import com.mindpin.application.MindpinApplication;
import com.mindpin.database.FeedHold;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;

public class SendFeedHoldThread extends Thread{
	public static final int MESSAGE_SEND_FEED_HOLD = 0;
	private Handler mHandler;
	private MindpinApplication app;

    public SendFeedHoldThread(MindpinApplication app) {
		super();
		this.app = app;
	}

	public void run() {
        Looper.prepare();

        mHandler = new Handler() {
            public void handleMessage(Message msg) {
            	switch (msg.what) {
				case MESSAGE_SEND_FEED_HOLD:
					send_feed_holds();
					break;
				}
            }
        };
        app.send_feed_hold_handler = mHandler;
        Looper.loop();
    }
    
	public void send_feed_holds() {
		System.out.println("FEED_HOLD COUNT "+ FeedHold.get_count(app));
		try {
			if (FeedHold.get_count(app) != 0) {
				FeedHoldManager.send_feed_holds(app);
				AccountManager.touch_last_syn_time(app);
				Notification notification = new Notification(
						android.R.drawable.ic_menu_save, "mindpin，主题数据已经提交",
						System.currentTimeMillis());
				Intent msg_intent = new Intent();
				PendingIntent intent = PendingIntent.getActivity(
						app, 0, msg_intent,
						Intent.FLAG_ACTIVITY_NEW_TASK);
				notification.setLatestEventInfo(app,
						"mindpin，主题数据已经提交", "", intent);
				NotificationManager nm = (NotificationManager)app.getSystemService(Service.NOTIFICATION_SERVICE);
				nm.notify(0, notification);
			}
		} catch (IntentException e) {
			e.printStackTrace();
		}
	}
}
