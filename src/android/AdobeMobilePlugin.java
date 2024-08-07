/*
 Copyright 2020 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

 package com.adobe.marketing.mobile.cordova;


 import static com.adobe.marketing.mobile.messaging.MessagingConstants.LOG_TAG;
 import android.util.Log;
 import com.adobe.marketing.mobile.Edge;
 import com.adobe.marketing.mobile.Extension;
 import com.adobe.marketing.mobile.Lifecycle;
 import com.adobe.marketing.mobile.MobileCore;
 import com.adobe.marketing.mobile.edge.consent.Consent;
 import com.adobe.marketing.mobile.edge.identity.Identity;
 import org.apache.cordova.CordovaPlugin;
 import org.apache.cordova.CallbackContext;
 import org.json.JSONArray;
 import org.json.JSONObject;
 import java.util.Arrays;
 import java.util.List;
 
 public class AdobeMobilePlugin extends CordovaPlugin {

     @Override
     public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {
         if("configureWithAppID".equals(action)) {
             try {

                 String applicationID = args.getString(0);
                 if(applicationID == null || applicationID.isEmpty()) {
                     callbackContext.error("You need to pass the application ID to the Adobe SDK initialization");
                     return true;
                 }

                 MobileCore.configureWithAppID(applicationID);
                 List<Class<? extends Extension>> extensions = Arrays.asList(
                         Edge.EXTENSION,
                         Consent.EXTENSION,
                         Lifecycle.EXTENSION,
                         Identity.EXTENSION
                 );

                 MobileCore.registerExtensions(extensions, o -> Log.d(LOG_TAG, "AEP Mobile SDK is initialized"));
                 callbackContext.success("Adobe SDK is initialized with success!");
             } catch (Exception ex) {
                 callbackContext.error("You need to pass the application ID to the Adobe SDK initialization");
             }
             return true;
         }

         if ("getConsents".equals(action)) {
             getConsents(callbackContext);
             return true;
         }
 
         if ("lifecycleStart".equals(action)) {
             lifecycleStart(callbackContext);
             return true;
         }
 
         if ("lifecyclePause".equals(action)) {
             lifecyclePause(callbackContext);
             return true;
         }
 
         return false;
     }

     private void getConsents(final CallbackContext callbackContext) {
         cordova.getThreadPool().execute(() -> Consent.getConsents(consents -> {
             JSONObject jsonObject = new JSONObject(consents);
             callbackContext.success(jsonObject);
         }));
     }
 
     private void lifecycleStart(final CallbackContext callbackContext) {
         cordova.getThreadPool().execute(new Runnable() {
             @Override
             public void run() {
                 MobileCore.lifecycleStart(null);
                 callbackContext.success();
             }
         });
     }
 
     private void lifecyclePause(final CallbackContext callbackContext) {
         cordova.getThreadPool().execute(new Runnable() {
             @Override
             public void run() {
                 MobileCore.lifecyclePause();
                 callbackContext.success();
             }
         });
     }
 }