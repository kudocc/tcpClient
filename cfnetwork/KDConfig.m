//
//  KDConfig.m
//  cfnetwork
//
//  Created by yuanrui on 15-1-22.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "KDConfig.h"

@implementation KDConfig

+ (KDConfig *)sharedConfig
{
    static KDConfig *sharedInstance = nil ;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[KDConfig alloc] init] ;
    }) ;
    return sharedInstance ;
}

- (id)init
{
    self = [super init] ;
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"] ;
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path] ;
        _serverIp = dict[@"serverIp"] ;
        _serverPort = [dict[@"serverPort"] unsignedShortValue] ;
    }
    return self ;
}

@end