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


 import com.adobe.marketing.mobile.AdobeCallbackWithError;
 import com.adobe.marketing.mobile.AdobeError;
 import com.adobe.marketing.mobile.Edge;
 import com.adobe.marketing.mobile.Extension;
 import com.adobe.marketing.mobile.Lifecycle;
 import com.adobe.marketing.mobile.MobileCore;
 import com.adobe.marketing.mobile.edge.consent.Consent;
 import com.adobe.marketing.mobile.Identity;
 import org.apache.cordova.CordovaPlugin;
 import org.apache.cordova.CallbackContext;
 import org.json.JSONArray;
 import org.json.JSONException;
 import org.json.JSONObject;
 import java.util.Arrays;
 import java.util.HashMap;
 import java.util.List;
 import java.util.Map;

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

                 MobileCore.registerExtensions(extensions, new AdobeCallbackWithError<Object>() {
                     @Override
                     public void fail(AdobeError adobeError) {
                         callbackContext.success("Error to initialize "+adobeError.getErrorName());
                     }

                     @Override
                     public void call(Object o) {
                         callbackContext.success("Adobe SDK is initialized with success!");
                     }
                 });
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

         if ("updateConsents".equals(action)) {
             updateConsents(args, callbackContext);
             return true;
         }
 
         return false;
     }

     private void getConsents(final CallbackContext callbackContext) {
         Consent.getConsents(new AdobeCallbackWithError<Map<String, Object>>() {
             @Override
             public void fail(AdobeError adobeError) {
                 callbackContext.error("Error to get getConsents "+adobeError.getErrorName());
             }

             @Override
             public void call(Map<String, Object> consents) {
                 JSONObject jsonObject = new JSONObject(consents);
                 callbackContext.success(jsonObject);
             }
         });
     }

     private void updateConsents(JSONArray args, CallbackContext callbackContext) {
         try {
             if (args == null || args.getString(0) == null) {
                 callbackContext.error("The argument Opt-In/Out-Out cannot be empty!");
             } else {
                 Consent.getConsents(new AdobeCallbackWithError<Map<String, Object>>() {
                     @Override
                     public void fail(AdobeError adobeError) {
                         callbackContext.error("Error to get update consents cause "+adobeError.getErrorName());
                     }

                     @Override
                     public void call(Map<String, Object> consents) {
                         if (consents.isEmpty()) {
                             callbackContext.error("Consents is empty, no updated!");
                         } else {

                             try {
                                 String value = args.getString(0);

                                 final Map<String, Object> collectConsents = new HashMap<>();
                                 collectConsents.put("collect", new HashMap<String, String>() {
                                     {
                                         put("val", value);
                                     }
                                 });
                                 consents.put("consents", collectConsents);

                                 Consent.update(consents);
                                 callbackContext.success();
                             } catch (JSONException e) {
                                 callbackContext.error("The argument Opt-In/Out-Out cannot be empty!");
                             }
                         }
                     }
                 });
             }
         } catch (Exception ex) {
             callbackContext.error("Error to get update consents cause "+ex.getMessage());
         }
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