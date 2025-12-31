//package com.actuajeriko.eypop;
//
//import android.os.Handler;
//
//import app.loup.streams_channel.StreamsChannel;
//import io.flutter.embedding.engine.plugins.FlutterPlugin;
//import io.flutter.plugin.common.EventChannel;
//import io.flutter.plugin.common.PluginRegistry;
//import android.content.Intent;
//import android.util.Log;
//
//public class PluginExample implements FlutterPlugin {
//
//
//    @Override
//    public void onAttachedToEngine(FlutterPluginBinding binding) {
//        final StreamsChannel channel = new StreamsChannel(binding.getBinaryMessenger(), "streams_channel_example");
//        channel.setStreamHandlerFactory(arguments -> new StreamHandler());
//    }
//
//    @Override
//    public void onDetachedFromEngine(FlutterPluginBinding binding) {
//
//    }
//    /// Live Stream channel
//    public static class StreamHandler implements EventChannel.StreamHandler {
//        private final Handler handler = new Handler();
//        private final Runnable runnable = new Runnable() {
//
//            @Override
//            public void run() {
//                Intent intent = Receiver.messenger;
//                if (intent!=null) {
//                    android.util.Log.e("TAG", "run: " + intent);
//                    eventSink.success(intent.getStringExtra("com.parse.Data"));
//                }
//                handler.postDelayed(this, 1000);
//                Receiver.messenger = null;
//
//
//            }
//
//        };
//
//        private EventChannel.EventSink eventSink;
//
//        @Override
//        public void onListen(Object o, final EventChannel.EventSink eventSink) {
//            System.out.println("StreamHandler - onListen: " + o);
//            this.eventSink = eventSink;
//            runnable.run();
//        }
//
//        @Override
//        public void onCancel(Object o) {
//            System.out.println("StreamHandler - onCancel: " + o);
//            handler.removeCallbacks(runnable);
//        }
//    }
//}