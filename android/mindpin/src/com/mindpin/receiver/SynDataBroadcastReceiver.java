package com.mindpin.receiver;

import java.util.Timer;
import java.util.TimerTask;
import com.mindpin.Logic.Http;
import com.mindpin.base.task.MindpinAsyncTask;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class SynDataBroadcastReceiver extends BroadcastReceiver {

	@Override
	public void onReceive(final Context context, Intent intent) {
		new MindpinAsyncTask<String, Integer, Void>() {

			public void on_start() {
				send_progress_broadcast(context, 0);
				System.out.println("task on start!!");
			};

			@Override
			public Void do_in_background(String... params) throws Exception {
				Timer timer = new Timer();

				try {
					TimerTask timer_task = new TimerTask() {
						@Override
						public void run() {
							send_progress_broadcast(context, 1);
						}
					};
					timer.schedule(timer_task, 50, 50);
					Http.mobile_data_syn();

					send_progress_broadcast(context, 100);

					Thread.sleep(500);

					return null;
				} catch (Exception e) {
					throw e;
				} finally {
					timer.cancel();
				}
			}

			public void on_success(Void v) {
				send_progress_broadcast(context, 101);
			}

			public boolean on_unknown_exception() {
				send_progress_broadcast(context, -1);
				return false;
			};
		}.execute();

	}

	private void send_progress_broadcast(Context context, int progress) {
		System.out.println("send progress broadcast " + progress);
		Intent i = new Intent(BroadcastReceiverConstants.ACTION_SYN_DATA_UI);
		i.putExtra("progress", progress);
		context.sendBroadcast(i);
	}

}
