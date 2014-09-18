//
//  KDPacket.h
//  cfnetwork
//
//  Created by yuanrui on 14-8-12.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkHeader.h"

@protocol PacketDelegate ;
@interface KDPacket : NSObject

// send
@property (nonatomic, assign) uint32_t sendPosition ;
+ (id)serialization:(BaseNetworkPacket *)basePacket ;
- (NSData *)data ;

// revc
+ (id)deSerialization:(NSData *)data ;
- (BaseNetworkPacket *)packet ;

@property (nonatomic, weak) id<PacketDelegate> delegate ;

@end

@protocol PacketDelegate <NSObject>

- (void)packetTimeout:(KDPacket *)p ;
- (void)packetConnectionDisconnected:(KDPacket *)p ;

@end