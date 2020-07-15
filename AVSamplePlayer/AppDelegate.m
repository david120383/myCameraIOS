//
//  AppDelegate.m
//  AVSamplePlayer
//
//  Created by bingcai on 16/6/27.
//  Copyright © 2016年 sharetronic. All rights reserved.
//

#import "AppDelegate.h"
#import "IOTCAPIs.h"
//#import "AVAPIs.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    NSLog(@"didFinishLaunchingWithOptions...");
//    NSLog(@"当程序载入后执行****************START");
////    TUTK 手机客户端注意事项
////    https://blog.csdn.net/imlsq/article/details/48781451
//    int ret;
////    ret = IOTC_Initialize2(0);
//    ret = IOTC_Initialize(0, "46.137.188.54", "122.226.84.253", "m2.iotcplatform.com", "m5.iotcplatform.com");
//    NSLog(@"IOTC_Initialize() ret = %d", ret);
////    IOTC_ER_NoERROR = 0
//    if (ret != IOTC_ER_NoERROR) {
//        NSLog(@"IOTCAPIs exit...");
////        return NULL;
//    }
//    NSLog(@"当程序载入后执行****************END");
    return YES;
}

- (void)test {

    uint8_t a[10] = {0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x1a, 0x1b, 0x1c, 0x0d};
    uint8_t b[5] = {0x0a, 0x0b, 0x0c, 0x0d, 0x0e};
    uint8_t *srcData[2];
    srcData[0] = a;
    srcData[1] = b;
    uint8_t *dst = (uint8_t *)malloc(8);
    memcpy(dst, srcData[0] + 2, 8);
    
    NSString *string1 = @"";
    for (int i = 0; i < 8; i ++) {
        NSString *temp = [NSString stringWithFormat:@"%x", *(dst + i)&0xff];
        if ([temp length] == 1) {
            temp = [NSString stringWithFormat:@"0%@", temp];
        }
        string1 = [string1 stringByAppendingString:temp];
    }
    NSLog(@"%@",string1);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground...");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground...");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
