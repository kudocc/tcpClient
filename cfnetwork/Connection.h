//
//  Connection.h
//  cfnetwork
//
//  Created by KudoCC on 14-9-18.
//  Copyright (c) 2014年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KDPacket ;
@protocol Connection <NSObject>

- (BOOL)isConnect ;
- (void)connect ;
- (void)closeConnection ;
- (void)sendData:(KDPacket *)packet ;

@end


@protocol ConnectionDelegate <NSObject>

@required
- (NSString *)ipAddress ;
- (uint16_t)port ;

- (void)dataReceived:(KDPacket *)packet ;
@optional
- (void)connectionDidConnect ;
- (void)connectionDidDisconnect ;

- (void)connectionFailWithError:(int)error ;

@end