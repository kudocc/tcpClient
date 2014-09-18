//
//  KDPacket.m
//  cfnetwork
//
//  Created by yuanrui on 14-8-12.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#import "KDPacket.h"
#import "KDNetworkUtility.h"

@interface KDPacket ()

@property (nonatomic, strong) NSData *privateData ;

@end

@implementation KDPacket
{
    BaseNetworkPacket *pBasePacket ;
}

// serialization
- (id)initWithBasePacket:(BaseNetworkPacket *)packet
{
    self = [super init] ;
    if (self) {
        switch (packet->header.cmd) {
            case Cmd_Text:
            {
                TextPacket *p = (TextPacket *)packet ;
                pBasePacket = new TextPacket(*p) ;
            }
                break;
            default:
                break;
        }
        uint32_t packetLen = packet->packetLength() ;
        uint8_t *mem = (uint8_t *)malloc(packetLen) ;
        CSerialization *serial = new CSerialization(mem, packetLen) ;
        packet->serialization(serial) ;
        delete serial ;
        _privateData = [NSData dataWithBytesNoCopy:mem length:packetLen freeWhenDone:YES] ;
    }
    return self ;
}

// deserialization
- (id)initWithData:(NSData *)data
{
    self = [super init] ;
    if (self) {
        CDeserialization *deSerial = new CDeserialization((const uint8_t *)data.bytes, [data length]) ;
        BaseNetworkPacket basePacket ;
        basePacket.deSerialization(deSerial) ;
        deSerial->reset() ;
        switch (basePacket.header.cmd) {
            case Cmd_Text:
            {
                pBasePacket = new TextPacket() ;
                pBasePacket->deSerialization(deSerial) ;
            }
                break;
            default:
                break;
        }
        _privateData = data ;
    }
    return self ;
}

- (void)dealloc
{
    delete pBasePacket ;
}

+ (id)serialization:(BaseNetworkPacket *)basePacket
{
    KDPacket *packet = [[KDPacket alloc] initWithBasePacket:basePacket] ;
    return packet ;
}

- (NSData *)data
{
    return _privateData ;
}

+ (id)deSerialization:(NSData *)data
{
    KDPacket *packet = [[KDPacket alloc] initWithData:data] ;
    return packet ;
}

- (BaseNetworkPacket *)packet
{
    return pBasePacket ;
}

@end