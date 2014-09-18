//
//  KDCFNetworkConnection.h
//  cfnetwork
//
//  Created by yuanrui on 14-9-18.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

@interface KDCFNetworkConnection : NSObject<Connection>

@property (nonatomic, weak, readonly) id<ConnectionDelegate> delegate ;

- (id)initWithDelegate:(id<ConnectionDelegate>)aDelegate ;

@end
