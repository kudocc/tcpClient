//
//  UIDevice+Network.h
//  cfnetwork
//
//  Created by yuanrui on 14-8-27.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface UIDevice (Network)

+ (NSString *)descriptionOfSCNetworkReachabilityFlag:(SCNetworkReachabilityFlags)flags ;

- (NSString *)localIp ;

@end
