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
 import com.adobe.marketing.mobile.Assurance;
 import com.adobe.marketing.mobile.Edge;
 import com.adobe.marketing.mobile.ExperienceEvent;
 import com.adobe.marketing.mobile.Extension;
 import com.adobe.marketing.mobile.Identity;
 import com.adobe.marketing.mobile.Lifecycle;
 import com.adobe.marketing.mobile.MobileCore;
 import com.adobe.marketing.mobile.edge.consent.Consent;
 
 import org.apache.cordova.CordovaPlugin;
 import org.apache.cordova.CallbackContext;
 import org.json.JSONArray;
 import org.json.JSONException;
 import org.json.JSONObject;
 
 import java.util.Arrays;
 import java.util.HashMap;
 import java.util.Iterator;
 import java.util.List;
 import java.util.Map;
 import com.google.gson.Gson;
 
 import com.adobe.marketing.mobile.LoggingMode;
 import com.adobe.marketing.mobile.Messaging;
 import com.adobe.marketing.mobile.Signal;
 import com.adobe.marketing.mobile.UserProfile;
 import com.adobe.marketing.mobile.edge.identity.AuthenticatedState;
 import com.adobe.marketing.mobile.edge.identity.IdentityItem;
 import com.adobe.marketing.mobile.edge.identity.IdentityMap;
 
 public class AdobeMobilePlugin extends CordovaPlugin {
 
     @Override
     protected void pluginInitialize() {
         super.pluginInitialize();
 
         MobileCore.setApplication(this.cordova.getActivity().getApplication());
         MobileCore.setLogLevel(LoggingMode.DEBUG);
     }
 
     @Override
     public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {
         if ("configureWithAppID".equals(action)) {
             try {
                 String applicationID = args.getString(0);
                 List<Class<? extends Extension>> extensions = Arrays.asList(
                         Messaging.EXTENSION,
                         Edge.EXTENSION,
                         Assurance.EXTENSION,
                         Consent.EXTENSION,
                         Identity.EXTENSION,
                         com.adobe.marketing.mobile.edge.identity.Identity.EXTENSION,
                         com.adobe.marketing.mobile.Identity.EXTENSION,
                         UserProfile.EXTENSION,
                         Lifecycle.EXTENSION,
                         Signal.EXTENSION
                 );
 
                 MobileCore.registerExtensions(extensions, new AdobeCallbackWithError<Object>() {
                     @Override
                     public void fail(AdobeError adobeError) {callbackContext.success("Error to initialize " + adobeError.getErrorName());}
                     @Override
                     public void call(Object o) {
                         MobileCore.configureWithAppID(applicationID);
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
 
         if ("startSession".equals(action)) {
             startAdobeSession(args, callbackContext);
             return true;
         }

         if ("updateConfigurationWith".equals(action)) {
            // Do nothing for Android do not need
            return true;
        }
 
         if ("setPushIdentifier".equals(action)) {
             try {
                 String token = args.getString(0);
                 if (token == null) {
                     callbackContext.error("You need to pass the token to use push registration");
                 } else {
                     MobileCore.setPushIdentifier(token);
                     callbackContext.success();
                 }
             } catch (Exception ex) {
                 callbackContext.error("You need to pass the token to use push registration");
             }
             return true;
         }
 
         if ("sendEvent".equals(action)) {
             sendEvent(args, callbackContext);
             return true;
         }
 
         if ("updateIdentities".equals(action)) {
             updateIdentities(args, callbackContext);
             return true;
         }
 
         if ("removeIdentity".equals(action)) {
             removeIdentity(args, callbackContext);
             return true;
         }
 
         return false;
     }
 
     private void updateIdentities(final JSONArray args, final CallbackContext callbackContext) {
        try {

            String identityKey = args.getString(0);
            String identityValue = args.getString(1);
            String authenticatedState = args.getString(2);
            boolean isPrimary = args.getBoolean(3);
            AuthenticatedState state = AuthenticatedState.valueOf(authenticatedState);

            IdentityItem item = new IdentityItem(identityValue, state, isPrimary);
            IdentityMap identityMap = new IdentityMap();
            identityMap.addItem(item, identityKey);

            com.adobe.marketing.mobile.edge.identity.Identity.updateIdentities(identityMap);
            callbackContext.success();
        } catch (Exception ex) {
            callbackContext.error("Error to updateIdentities error: "+ex.getMessage());
        }
    }
 
     private void removeIdentity(final JSONArray args, final CallbackContext callbackContext) {
         try {
             String identityKey = args.getString(0);
             String identityValue = args.getString(1);
             IdentityItem item = new IdentityItem(identityValue);
             com.adobe.marketing.mobile.edge.identity.Identity.removeIdentity(item, identityKey);
             callbackContext.success();
         } catch (Exception ex) {
             callbackContext.error("Error to removeIdentities error: "+ex.getMessage());
         }
     }
 
     private void sendEvent(final JSONArray args, final CallbackContext callbackContext) {
         try {
 
             String eventValue = args.getString(0);
             String eventType = args.getString(1);
             JSONObject contextData = args.getJSONObject(2);
 
             Map<String, Object> xdmData = new HashMap<>();
             xdmData.put("eventType", eventValue);
             xdmData.put(eventType, toMap(contextData));
 
             ExperienceEvent experienceEvent = new ExperienceEvent.Builder()
                     .setXdmSchema(xdmData)
                     .build();
 
             Edge.sendEvent(experienceEvent, list -> callbackContext.success());
         } catch (Exception ex) {
             callbackContext.error("eventType or eventValue is null, please review your implementation");
         }
     }
 
     private Map<String, Object> toMap(JSONObject jsonObject) throws JSONException {
         Map<String, Object> map = new HashMap<>();
         Iterator<String> keys = jsonObject.keys();
 
         while (keys.hasNext()) {
             String key = keys.next();
             Object value = jsonObject.get(key);
 
             if (value instanceof JSONObject) {
                 value = toMap((JSONObject) value);
             }
             map.put(key, value);
         }
 
         return map;
     }
 
     private void startAdobeSession(JSONArray args, CallbackContext callbackContext) {
         try {
             String url = args.getString(0);
             if (args.getString(0).equals("null")) {
                 callbackContext.error("You need to pass the url session to the Adobe SDK");
             } else {
                 Assurance.startSession(url);
                 callbackContext.success();
             }
         } catch (Exception ex) {
             callbackContext.error("You need to pass the application ID to the Adobe SDK initialization");
         }
     }
 
     private void getConsents(final CallbackContext callbackContext) {
         Consent.getConsents(new AdobeCallbackWithError<Map<String, Object>>() {
             @Override
             public void fail(AdobeError adobeError) {
                 callbackContext.error("Error to get getConsents " + adobeError.getErrorName());
             }
 
             @Override
             public void call(Map<String, Object> consents) {
                Gson gson = new Gson();
                String json = gson.toJson(consents);
                callbackContext.success(json);
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
                         callbackContext.error("Error to get update consents cause " + adobeError.getErrorName());
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
             callbackContext.error("Error to get update consents cause " + ex.getMessage());
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