//
//  KDPacketSendList.h
//  cfnetwork
//
//  Created by KudoCC on 14-9-4.
//  Copyright (c) 2014年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDPacket.h"
@interface KDPacketSendList : NSObject

- (KDPacket *)packetAtIndex:(NSUInteger)index ;
- (NSUInteger)packetCount ;

- (void)removePacketWithTransId:(uint32_t)transId ;
- (void)removePacket:(KDPacket *)packet ;
- (void)addPacket:(KDPacket *)packet ;

@end
