//
//  KDCFNetworkConnection.m
//  cfnetwork
//
//  Created by yuanrui on 14-9-18.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#import "KDCFNetworkConnection.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import "KDPacket.h"
#import "PacketMemoryManager.h"
#import "KDPacketSendList.h"
#import "KDNetworkUtility.h"

typedef enum eNetworkState {
    NetworkStateDisconnect = 0,
    NetworkStateConnecting,
    NetworkStateConnected,
} NetworkState ;

@interface KDCFNetworkConnection ()
{
    CPacketMemoryManager manager ;
}

@property (nonatomic, weak, readwrite) id<ConnectionDelegate> delegate ;

@property (nonatomic, strong) NSThread *threadNetwork ;
@property (nonatomic, assign) NetworkState networkState ;
@property (nonatomic, strong) KDPacketSendList *packetSendList ;

@property (nonatomic, strong) NSInputStream *inputStream ;
@property (nonatomic, strong) NSOutputStream *outputStream ;

@end

@implementation KDCFNetworkConnection

- (id)initWithDelegate:(id<ConnectionDelegate>)aDelegate
{
    self = [super init] ;
    if (self) {
        _networkState = NetworkStateDisconnect ;
        _packetSendList = [[KDPacketSendList alloc] init] ;
        _delegate = aDelegate ;
    }
    return self ;
}

- (void)dealloc
{
    if (_threadNetwork && ![_threadNetwork isCancelled]) {
        [_threadNetwork cancel] ;
    }
}

#pragma mark - Connection

- (BOOL)isConnect
{
    return _networkState == NetworkStateConnected ;
}

- (void)connect
{
    if (!_threadNetwork) {
        _threadNetwork = [[NSThread alloc] initWithTarget:self selector:@selector(threadEntry) object:nil] ;
        [_threadNetwork start] ;
    }
}

- (void)closeConnection
{
    if (_threadNetwork && ![_threadNetwork isCancelled]) {
        [_threadNetwork cancel] ;
    }
}

#pragma mark - read & write

void readStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType event, void *myPtr)
{
    @autoreleasepool {
        KDCFNetworkConnection *p_self = (__bridge KDCFNetworkConnection *)myPtr ;
        CPacketMemoryManager *pManager = &(p_self->manager) ;
        
        if ((event & kCFStreamEventHasBytesAvailable) != 0) {
            UInt8 bufferRead[2048] ;
            CFIndex bytesRead = 0 ;
            do {
                bytesRead = CFReadStreamRead(stream, bufferRead, sizeof(bufferRead)) ;
                if (bytesRead > 0) {
                    NSLog(@"read len %ld", bytesRead) ;
                    pManager->addToBuffer(bufferRead, bytesRead) ;
                    if (!CFReadStreamHasBytesAvailable(stream)) {
                        break ;
                    }
                }
            } while (bytesRead > 0) ;
            while (1) {
                unsigned int len = pManager->getUseBufferLength() ;
                if (len > sizeof(BaseNetworkPacket)) {
                    unsigned char *p = pManager->getBufferPointer() ;
                    NSData *data = [NSData dataWithBytes:p length:sizeof(BaseNetworkPacket)] ;
                    KDPacket *packet = [KDPacket deSerialization:data] ;
                    unsigned int packetLen = packet.packet->header.length ;
                    if (len < packetLen) {
                        break ;
                    }
                    data = [NSData dataWithBytes:p length:packetLen] ;
                    packet = [KDPacket deSerialization:data] ;
                    pManager->removeBuffer(packetLen) ;
                    
                    BaseNetworkPacket *basePacket = [packet packet] ;
                    if (basePacket->header.cmd == Cmd_Text) {
                        TextPacket *textpacket = (TextPacket *)basePacket ;
                        textpacket->text[textpacket->textLen] = '\0' ;
                        [p_self.delegate dataReceived:packet] ;
                    }
                } else {
                    break ;
                }
            }
        }
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
            NSLog(@"app in background") ;
        }
        
        if ((event & kCFStreamEventErrorOccurred) != 0) {
            NSInputStream *s = (__bridge NSInputStream *)stream ;
            NSLog(@"read stream error %@", [s streamError]) ;
            NSThread *thread = [NSThread currentThread] ;
            [thread cancel] ;
        }
        
        if ((event & kCFStreamEventEndEncountered) != 0) {
            NSLog(@"A Read Stream Event End!") ;
            NSThread *thread = [NSThread currentThread] ;
            [thread cancel] ;
        }
    }
}

void writeStreamClientCallBack(CFWriteStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
{
    @autoreleasepool {
        if (type & kCFStreamEventErrorOccurred) {
            NSOutputStream *s = (__bridge NSOutputStream *)stream ;
            NSLog(@"write stream error %@", [s streamError]) ;
            NSThread *thread = [NSThread currentThread] ;
            [thread cancel] ;
        }
        if (type & kCFStreamEventEndEncountered) {
            NSLog(@"write stream end") ;
            NSThread *thread = [NSThread currentThread] ;
            [thread cancel] ;
        }
    }
}

- (void)threadEntry
{
    @autoreleasepool {
        CFReadStreamRef readStreamRef = nil ;
        CFWriteStreamRef writeStreamRef = nil ;
        NSString *strIp = [_delegate ipAddress] ;
        uint16_t port = [_delegate port] ;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)strIp, port, &readStreamRef, &writeStreamRef) ;
        CFStreamClientContext myContext = {
            0,
            (__bridge void *)self,
            NULL,
            NULL,
            NULL
        };
        CFOptionFlags registeredEventsR = kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered ;
        CFOptionFlags registeredEventsW = kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered ;
        CFReadStreamSetClient(readStreamRef, registeredEventsR, readStreamClientCallBack, &myContext) ;
        CFWriteStreamSetClient(writeStreamRef, registeredEventsW, writeStreamClientCallBack, &myContext) ;
        
        CFReadStreamScheduleWithRunLoop(readStreamRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode) ;
        CFWriteStreamScheduleWithRunLoop(writeStreamRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode) ;
        
        _inputStream = (__bridge_transfer NSInputStream *)readStreamRef ;
        _outputStream = (__bridge_transfer NSOutputStream *)writeStreamRef ;
        
        BOOL bSetProperty = [_inputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType] ;
        NSLog(@"set NSStreamNetworkServiceTypeVoIP on read stream %u", bSetProperty) ;
        bSetProperty = [_outputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType] ;
        NSLog(@"set NSStreamNetworkServiceTypeVoIP on write stream %u", bSetProperty) ;
        
        [_inputStream open] ;
        [_outputStream open] ;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate connectionDidConnect] ;
            self.networkState = NetworkStateConnected ;
        }) ;
        
        while (![_threadNetwork isCancelled]) {
            SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 4.0, true) ;
            switch (result) {
                case kCFRunLoopRunFinished:
                    NSLog(@"kCFRunLoopRunFinished") ;
                    break;
                case kCFRunLoopRunStopped:
                    NSLog(@"kCFRunLoopRunStopped") ;
                    break ;
                case kCFRunLoopRunTimedOut:
                    NSLog(@"kCFRunLoopRunTimedOut") ;
                    break ;
                case kCFRunLoopRunHandledSource:
                    NSLog(@"kCFRunLoopRunHandledSource") ;
                    break ;
                default:
                    break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate connectionDidDisconnect] ;
            self.networkState = NetworkStateDisconnect ;
        }) ;
        
        [_inputStream close] ;
        [_outputStream close] ;
        
        _inputStream = nil ;
        _outputStream = nil ;
        
        NSLog(@"thread stoped") ;
    }
}

- (void)sendData:(KDPacket *)packet
{
    [_packetSendList addPacket:packet] ;
    
    NSMutableArray *mArrayRemovePacket = [NSMutableArray array] ;
    for (NSUInteger i = 0; i < [_packetSendList packetCount]; ++i) {
        KDPacket *p = [_packetSendList packetAtIndex:i] ;
        NSData *data = [packet data] ;
        const char *pointer = (const char *)data.bytes + p.sendPosition ;
        NSInteger l = 0 ;
        while (1) {
            l = [_outputStream write:(const uint8_t *)pointer maxLength:[data length]-p.sendPosition] ;
            if (l > 0) {
                p.sendPosition += l ;
                if (p.sendPosition >= [data length]) {
                    // add the packet to remove list
                    [mArrayRemovePacket addObject:p] ;
                    break ;
                }
                NSLog(@"send data len:%zd", l) ;
            } else {
                break ;
            }
        }
    }
    for (KDPacket *p in mArrayRemovePacket) {
        [_packetSendList removePacket:p] ;
    }
}

@end
