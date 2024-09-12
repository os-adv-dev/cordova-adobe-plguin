package com.adobe.marketing.mobile.cordova;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.adobe.marketing.mobile.Messaging;
import com.adobe.marketing.mobile.MessagingPushPayload;

public class NotificationDismissedReceiver extends BroadcastReceiver {

    private static final String TAG = NotificationDismissedReceiver.class.getSimpleName();

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.v(TAG, "onReceive -- to dismiss notification from Adobe SDK");
        Messaging.handleNotificationResponse(intent, false, MessagingPushPayload.ActionType.DISMISS.name().toLowerCase());
    }
}
