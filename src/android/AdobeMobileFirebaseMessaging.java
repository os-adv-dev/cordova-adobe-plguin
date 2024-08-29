package com.adobe.marketing.mobile.cordova;


import androidx.annotation.NonNull;

import com.adobe.marketing.mobile.MobileCore;
import com.google.firebase.messaging.RemoteMessage;
import com.outsystems.plugins.firebasemessaging.controller.FirebaseMessagingReceiveService;

public class AdobeMobileFirebaseMessaging extends FirebaseMessagingReceiveService {

    @Override
    public void onNewToken(@NonNull String token) {
        super.onNewToken(token);
        // Send the firebase token to Adobe SDK
        MobileCore.setPushIdentifier(token);
    }

    @Override
    public void onMessageReceived(@NonNull RemoteMessage message) {
        super.onMessageReceived(message);
    }
}