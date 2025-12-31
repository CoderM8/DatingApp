//package com.actuajeriko.eypop;
//
//import android.app.Notification;
//import android.app.PendingIntent;
//import android.content.Context;
//import android.content.Intent;
//import android.os.Bundle;
//import android.util.Log;
//
//
//import androidx.core.app.NotificationCompat;
//
////import com.parse.ParsePushBroadcastReceiver;
//
//import org.json.JSONException;
//import org.json.JSONObject;
//
//
//public class Receiver extends ParsePushBroadcastReceiver {
//    public static Intent messenger;
//
//
//    @Override
//    protected void onPushReceive(Context context, Intent intent) {
//
//        String pushDataStr = intent.getStringExtra(KEY_PUSH_DATA);
//        JSONObject pushData = null;
//        try {
//            assert pushDataStr != null;
//            pushData = new JSONObject(pushDataStr);
//        } catch (JSONException e) {
//            Log.e("TAG", "Unexpected JSONException when receiving push data: ", e);
//        }
//
//        if (MainActivity.activity==null ){
//            showNotificationMessage(context, intent);
//        }else {
//            if (App.getInstance().isAppOpened) {
////            showNotificationMessage(context, intent);
//                messenger = intent;
//
//            } else {
//
//                showNotificationMessage(context, intent);
//            }
//        }
//
//
//
//    }
//
//    private void showNotificationMessage(Context context, Intent intent) {
//        new MainActivity().backgroundnoti = intent;
//        messenger = intent;
//        NotificationUtils notificationUtils = new NotificationUtils(context);
//
//        String pushDataStr = intent.getStringExtra(KEY_PUSH_DATA);
//        if (pushDataStr == null) {
//            Log.v("TAG", "Can not get push data from intent.");
//            return;
//        }
//        Log.v("TAG", "Received push data: " + pushDataStr);
//
//        JSONObject pushData = null;
//        try {
//            pushData = new JSONObject(pushDataStr);
//        } catch (JSONException e) {
//            Log.e("TAG", "Unexpected JSONException when receiving push data: ", e);
//
//        }
//
//        // If the push data includes an action string, that broadcast intent is fired.
//        String action = null;
//        if (pushData != null) {
//            action = pushData.optString("action", null);
//
//            Log.e("TAG", "showNotificationMessage: " + action);
//
//        }
//        if (action != null) {
//            Bundle extras = intent.getExtras();
//            Intent broadcastIntent = new Intent();
//            assert extras != null;
//            broadcastIntent.putExtras(extras);
//            broadcastIntent.setAction(action);
//            broadcastIntent.setPackage(context.getPackageName());
//            context.sendBroadcast(broadcastIntent);
//        }
//
//        final NotificationCompat.Builder notificationBuilder = notificationUtils.getNotification(context, intent);
//
//
//        JSONObject finalPushData = pushData;
//
//
//        Intent myIntent = new Intent(context, MainActivity.class);
//
//        myIntent.putExtra("from", "notification");
//        myIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//        myIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
//        PendingIntent myPendingIntent = PendingIntent.getActivity(context, 0, myIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
//        assert notificationBuilder != null;
//        notificationBuilder.setContentIntent(myPendingIntent);
//
//
//        Notification notification;
//
//
//        notification = notificationBuilder.build();
//
//        ParseNotificationManager.getInstance().showNotification(context, notification);
//
//    }
//}
//
//
