//
//  PluginExample.m
//  Runner
//
//  Created by Lukasz on 2020-02-05.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "PluginExample.h"
#import <streams_channel3/FlutterStreamsChannel.h>
#import "Runner-Swift.h"
@interface StreamHandler : NSObject<FlutterStreamHandler>
  @property(strong, nonatomic) NSTimer *timer;
  @property(assign, nonatomic) NSInteger count;
//@property(strong, nonatomic) NSString *demoVariable;
@end

@implementation PluginExample


//struct GobalVariable{
//    @property(strong, nonatomic) NSString *demoVariable;
//
////    var demoVariable :NSString = "";
//
//}


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  
  FlutterStreamsChannel *channel = [FlutterStreamsChannel streamsChannelWithName:@"streams_channel_example" binaryMessenger:registrar.messenger];
  [channel setStreamHandlerFactory:^NSObject<FlutterStreamHandler> *(id arguments) {
    return [StreamHandler new];
  }];
}

@end

// Send "Hello" 10 times, every second, then ends the stream
@implementation StreamHandler

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
  NSLog(@"StreamHandler - onListen: %@", arguments);
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.demoVariable
    mainDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
  self.count = 1;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//    if(self.count > 10) {
//      events(FlutterEndOfEventStream);
//    } else {
//      events(AppDelegate.demoVariable);
        
        NSString *keyValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"Key"];
      //  NSLog(@"THE VALUE IS %@", keyValue);
      if (![keyValue  isEqual: @"Stop"]) {
          events(keyValue);

      }
      
      
      [[NSUserDefaults standardUserDefaults]setObject:@"Stop" forKey:@"Key"];
          [[NSUserDefaults standardUserDefaults] synchronize];
      
      
//      self.count++;
//    }
  }];
  
  return nil;
}



- (FlutterError *)onCancelWithArguments:(id)arguments {
  NSLog(@"StreamHandler - onCancel: %@", arguments);
  
  [self.timer invalidate];
  self.timer = nil;
  
  return nil;
}

@end
