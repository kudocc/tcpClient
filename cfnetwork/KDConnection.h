//
//  KDConnection.h
//  cfnetwork
//
//  Created by yuanrui on 14-9-17.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

@interface KDConnection : NSObject<Connection>

@property (nonatomic, weak, readonly) id<ConnectionDelegate> delegate ;

- (id)initWithDelegate:(id<ConnectionDelegate>)aDelegate ;

@end