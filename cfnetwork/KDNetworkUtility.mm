//
//  KDNetworkUtility.m
//  cfnetwork
//
//  Created by yuanrui on 14-9-2.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#import "KDNetworkUtility.h"

@implementation KDNetworkUtility

+ (unsigned int)generatorTransId
{
    static unsigned int transId = 0 ;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        transId = arc4random() ;
    }) ;
    if (++transId == 0xffffffff) {
        transId = 0 ;
    }
    return transId ;
}

@end
