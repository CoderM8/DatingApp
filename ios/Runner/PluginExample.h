//
//  PluginExample.h
//  Runner
//
//  Created by Lukasz on 2020-02-05.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <Flutter/Flutter.h>
 
@class AppDelegate;

@interface PluginExample : NSObject



+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

@end

AppDelegate *mainDelegate;
extern NSString *demoVariable2;
