//
//  KDPacketSendList.m
//  cfnetwork
//
//  Created by yuanrui on 14-9-4.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#import "KDPacketSendList.h"

@interface KDPacketSendList () <PacketDelegate>

@property (nonatomic, strong) NSMutableArray *mList ;

@end

@implementation KDPacketSendList

- (id)init
{
    self = [super init] ;
    if (self) {
        _mList = [NSMutableArray array] ;
    }
    return self ;
}

- (KDPacket *)packetAtIndex:(NSUInteger)index
{
    return _mList[index] ;
}

- (NSUInteger)packetCount
{
    return [_mList count] ;
}

- (void)removePacketWithTransId:(uint32_t)transId
{
    __block NSUInteger index = NSNotFound ;
    [_mList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        KDPacket *p = obj ;
        BaseNetworkPacket *base = [p packet] ;
        if (base->header.transId == transId) {
            index = idx ;
            *stop = YES ;
        }
    }] ;
    if (index != NSNotFound) {
        [_mList removeObjectAtIndex:index] ;
    }
}

- (void)removePacket:(KDPacket *)packet
{
    [_mList removeObject:packet] ;
}

- (void)addPacket:(KDPacket *)packet
{
    packet.delegate = self ;
    
    [_mList addObject:packet] ;
}

#pragma mark - PacketDelegate

- (void)packetTimeout:(KDPacket *)p
{
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), p) ;
}

- (void)packetConnectionDisconnected:(KDPacket *)p
{
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), p) ;
}

@end
