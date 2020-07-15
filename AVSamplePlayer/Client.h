//
//  Client.h
//  Sample_AVAPIs
//
//  Created by tutk on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClientDelegate <NSObject>

- (void)clientDidReceiveImage:(UIImage *)image;

@end

@interface Client : NSObject

//@property (copy,nonatomic) NSString *UID;
//@property (copy,nonatomic) NSString *account;
//@property (copy,nonatomic) NSString *password;

@property (copy,nonatomic) NSString *stop;

//@property (copy,nonatomic) NSString *mSID;
//@property (copy,nonatomic) NSString *mAvIndex;
//@property (nonatomic) pthread_t *join_thread_test;



- (pthread_t)start:(NSString *)clinetStartString;
//- (void)start_main:(NSString *)clientStartString;
//- (void)start:(NSString *)clinetStartString;
//- (void)start2:(NSString *)clinetStartString;
- (pthread_t)start:(NSString *)UID account:(NSString *)account password:(NSString *)password ;
//- (void)start_main2:(NSString *)arguments;

@end
