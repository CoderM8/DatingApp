package com.actuajeriko.eypop;

import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

public class MainActivity extends FlutterActivity {

    private static final int PERMISSION_REQUEST_CODE = 101;

    private static final String CHANNEL = "MainActivity";
    private static final String CHANNEL2 = "Receiver";
    public static Intent backgroundnoti;
    public static MainActivity activity;


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
//        flutterEngine.getPlugins().add(new PluginExample());

        activity = this;

        if (!checkPermission()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                requestPermission();
            }
        }


        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL2)
                .setMethodCallHandler((call, result) -> {
                            if (call.method.equals("ReceiverMethod")) {
                                Intent intent = getIntent();
                                if (intent != null) {
                                    String from = intent.hasExtra("from") ? intent.getStringExtra("from") : "";
                                    Log.e("TAG", "MainActivity notification data:" + from);
                                  if (from.equals("notification")) {
                                      if (backgroundnoti != null) {
                                          result.success(backgroundnoti.getStringExtra("com.parse.Data"));
                                      } else {
                                          result.success(null);
                                      }
                                  } else {
                                    result.success(null);
                                 }
                                } else {
                                    result.success(null);
                                }
                            } else {
                                result.success(null);
                            }
                        }
                );

    }

    private boolean checkPermission() {
        int result = 0;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            result = ContextCompat.checkSelfPermission(MainActivity.this, android.Manifest.permission.POST_NOTIFICATIONS);
        }
        return result == PackageManager.PERMISSION_GRANTED;
    }

    @RequiresApi(api = Build.VERSION_CODES.TIRAMISU)
    private void requestPermission() {
        if (ActivityCompat.shouldShowRequestPermissionRationale(MainActivity.this, android.Manifest.permission.POST_NOTIFICATIONS)) {
            Toast.makeText(MainActivity.this, "Write External Storage permission allows us to do store images. Please allow this permission in App Settings.", Toast.LENGTH_LONG).show();
        } else {
            ActivityCompat.requestPermissions(MainActivity.this, new String[]{android.Manifest.permission.POST_NOTIFICATIONS}, PERMISSION_REQUEST_CODE);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Log.e("value", "Permission Granted, Now you can use local drive .");
            } else {
                Log.e("value", "Permission Denied, You cannot use local drive .");
            }
        }
    }
}
