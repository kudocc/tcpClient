//
//  KDAppDelegate.h
//  cfnetwork
//
//  Created by yuanrui on 14-7-16.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestObj : NSObject

@property (nonatomic, assign) int value ;

@end

@interface KDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
