//package com.actuajeriko.eypop;
//
//import android.annotation.SuppressLint;
//import android.app.Activity;
//import android.app.Application;
//import android.os.Bundle;
//
//import androidx.annotation.NonNull;
//import androidx.annotation.Nullable;
//import androidx.lifecycle.LifecycleObserver;
//import androidx.lifecycle.ProcessLifecycleOwner;
//
////import com.parse.Parse;
////import com.parse.ParseInstallation;
//
//public class App extends Application implements LifecycleObserver, android.app.Application.ActivityLifecycleCallbacks {
//
//
//    ParseInstallation message;
//
//    @Override
//    public void onCreate() {
//        super.onCreate();
//
//        setInstance(this);
//        Instance = this;
//
//
//        registerActivityLifecycleCallbacks(this);
//        ProcessLifecycleOwner.get().getLifecycle().addObserver(this);
//
////        Parse.initialize(new Parse.Configuration.Builder(this)
////                .applicationId("YUwjJIdCFCiE1spXhebX2VmbtF9EJR1NUI7WQZ6k")
////                .clientKey("meu6pxIUqhlQ5iLLJuc490kAFI7Uz5ok5gk2qp1c")
////                .server("https://parseapi.back4app.com")
////                .build());
////                ParseInstallation.getCurrentInstallation().saveInBackground();
//
////        ParseInstallation installation = ParseInstallation.getCurrentInstallation();
////        installation.put("GCMSenderId", "985679342823");
////        installation.saveInBackground();
//    }
//
//
//    @SuppressLint("StaticFieldLeak")
//    protected static App Instance;
//
//    public void setInstance(App instance) {
//        App.Instance = instance;
//    }
//
//    public boolean isAppOpened = false;
//
//    public static synchronized App getInstance() {
//        return Instance;
//    }
//
//    public boolean isAppOpened() {
//        return isAppOpened;
//    }
//
//    @Override
//    public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle bundle) {
//        isAppOpened = true;
//    }
//
//    @Override
//    public void onActivityStarted(@NonNull Activity activity) {
//        isAppOpened = true;
//    }
//
//    @Override
//    public void onActivityResumed(@NonNull Activity activity) {
//        isAppOpened = true;
//    }
//
//    @Override
//    public void onActivityPaused(@NonNull Activity activity) {
//        isAppOpened = true;
//    }
//
//    @Override
//    public void onActivityStopped(@NonNull Activity activity) {
//        isAppOpened = false;
//    }
//
//    @Override
//    public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle bundle) {
//
//    }
//
//    @Override
//    public void onActivityDestroyed(@NonNull Activity activity) {
//        isAppOpened = false;
//    }
//}
//
