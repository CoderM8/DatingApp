//package com.actuajeriko.eypop;
//
//import android.app.Notification;
//import android.app.NotificationManager;
//import android.content.Context;
//import android.util.Log;
//
//import java.util.concurrent.atomic.AtomicInteger;
//
//
//class ParseNotificationManager {
//    private final AtomicInteger notificationCount = new AtomicInteger(0);
//
//    public static ParseNotificationManager getInstance() {
//        return Singleton.INSTANCE;
//    }
//
//    public void showNotification(Context context, Notification notification) {
//        if (context != null && notification != null) {
//            notificationCount.incrementAndGet();
//            // Fire off the notification
//            NotificationManager nm =
//                    (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
//
//            int notificationId = (int) System.currentTimeMillis();
//
//            try {
//                if (nm != null) {
//                    nm.notify(notificationId, notification);
//                }
//            } catch (SecurityException e) {
//                notification.defaults = Notification.DEFAULT_LIGHTS | Notification.DEFAULT_SOUND;
//                nm.notify(notificationId, notification);
//            }
//        }
//    }
//
//    private static class Singleton {
//        private static final ParseNotificationManager INSTANCE = new ParseNotificationManager();
//    }
//}
