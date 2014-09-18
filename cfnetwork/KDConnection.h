//
//  KDConnection.h
//  cfnetwork
//
//  Created by KudoCC on 14-9-17.
//  Copyright (c) 2014年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

@interface KDConnection : NSObject<Connection>

@property (nonatomic, weak, readonly) id<ConnectionDelegate> delegate ;

- (id)initWithDelegate:(id<ConnectionDelegate>)aDelegate ;

@end