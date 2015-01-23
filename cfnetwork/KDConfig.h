//
//  KDConfig.h
//  cfnetwork
//
//  Created by yuanrui on 15-1-22.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KDConfig : NSObject

+ (KDConfig *)sharedConfig ;

@property (nonatomic, strong) NSString *serverIp ;
@property (nonatomic, assign) uint16_t serverPort ;

@end
