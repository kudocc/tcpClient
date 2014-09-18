//
//  KDConnection.m
//  cfnetwork
//
//  Created by KudoCC on 14-9-17.
//  Copyright (c) 2014年 KudoCC. All rights reserved.
//

#import "KDConnection.h"
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

@interface KDConnection ()
{
    int clientSocket ;
}

@property (nonatomic, weak, readwrite) id<ConnectionDelegate> delegate ;

@property (nonatomic, strong) NSThread *threadNetwork ;
@property (nonatomic, assign) NetworkState networkState ;
@property (nonatomic, strong) KDPacketSendList *packetSendList ;

@end

@implementation KDConnection

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

- (BOOL)isConnect
{
    return _networkState == NetworkStateConnected ;
}

- (void)connect
{
    if (_threadNetwork) {
        return ;
    } else {
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

- (void)sendData:(KDPacket *)packet
{
    [_packetSendList addPacket:packet] ;
    
    NSMutableArray *mArrayRemovePacket = [NSMutableArray array] ;
    for (NSUInteger i = 0; i < [_packetSendList packetCount]; ++i) {
        KDPacket *p = [_packetSendList packetAtIndex:i] ;
        NSData *data = [packet data] ;
        const char *pointer = (const char *)data.bytes + p.sendPosition ;
        ssize_t l = 0 ;
        while (1) {
            l = write(clientSocket, pointer, [data length]-p.sendPosition) ;
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
        if (l < 0) {
            if (errno == EWOULDBLOCK) {
                NSLog(@"send buffer is full %d", errno) ;
            } else {
                [_threadNetwork cancel] ;
                NSLog(@"write socket error %d, stop the thread", errno) ;
            }
        }
    }
    for (KDPacket *p in mArrayRemovePacket) {
        [_packetSendList removePacket:p] ;
    }
}

#pragma mark - receive thread

- (void)threadEntry
{
    @autoreleasepool {
        uint16_t port = [_delegate port] ;
        NSString *strIp = [_delegate ipAddress] ;
        char ip[20] = {0} ;
        memset(ip, 0, sizeof(ip)) ;
        memcpy(ip, [strIp UTF8String], [strIp length]) ;
        
        clientSocket = socket(AF_INET, SOCK_STREAM, 0) ;
        struct sockaddr_in server_addr ;
        bzero(&server_addr, sizeof(server_addr)) ;
        server_addr.sin_port = htons(port) ;
        server_addr.sin_addr.s_addr = inet_addr(ip) ;
        server_addr.sin_family = AF_INET ;
        
        int i = connect(clientSocket, (const struct sockaddr *)&server_addr, sizeof(server_addr)) ;
        if (i >= 0) {
            /*
            if (_voipSupport) {
                CFReadStreamRef readStreamRef = nil ;
                CFWriteStreamRef writeStreamRef = nil ;
                CFStreamCreatePairWithSocket(NULL, clientSocket, &readStreamRef, &writeStreamRef) ;
                
                _inputStream = CFBridgingRelease(readStreamRef) ;
                _outputStream = CFBridgingRelease(writeStreamRef) ;
                BOOL bSetProperty = [_inputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType] ;
                NSLog(@"set NSStreamNetworkServiceTypeVoIP on read stream %u", bSetProperty) ;
                bSetProperty = [_outputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType] ;
                NSLog(@"set NSStreamNetworkServiceTypeVoIP on write stream %u", bSetProperty) ;
                [_inputStream open] ;
                [_outputStream open] ;
            }
            */
            dispatch_async(dispatch_get_main_queue(), ^{
                self.networkState = NetworkStateConnected ;
                [_delegate connectionDidConnect] ;
            }) ;
            
            // set clientSocket to O_NONBLOCK
            int val = fcntl(clientSocket, F_GETFL, 0) ;
            fcntl(clientSocket, F_SETFL, val | O_NONBLOCK) ;
            
            CPacketMemoryManager manager = CPacketMemoryManager() ;
            // select , time out is 1 second
            while (1 && ![_threadNetwork isCancelled]) {
                @autoreleasepool {
                    struct timeval timeout ;
                    timeout.tv_sec = 1 ;
                    timeout.tv_usec = 0 ;
                    
                    fd_set rSet ;
                    FD_ZERO(&rSet) ;
                    FD_SET(clientSocket, &rSet) ;
                    fd_set eSet ;
                    FD_ZERO(&eSet) ;
                    FD_SET(clientSocket, &eSet) ;
                    
                    int sel = select(clientSocket+1, &rSet, NULL, &eSet, &timeout) ;
                    if (sel == -1) {
                        if (errno == EINTR) {
                            continue ;
                        } else {
                            printf("select error %d\n", errno) ;
                            break ;
                        }
                    } else if (sel == 0) {
                        // time out
                        if ([_threadNetwork isCancelled]) {
                            break ;
                        }
                        continue ;
                    } else {
                        bool b = FD_ISSET(clientSocket, &rSet) ;
                        if (b) {
                            unsigned char bufferRead[2048] ;
                            long r = 0 ;
                            do {
                                r = read(clientSocket, bufferRead, sizeof(bufferRead)) ;
                                if (r > 0) {
                                    printf("read len %ld\n", r) ;
                                    manager.addToBuffer(bufferRead, r) ;
                                }
                            } while (r > 0) ;
                            while (1) {
                                unsigned int len = manager.getUseBufferLength() ;
                                if (len > sizeof(BaseNetworkPacket)) {
                                    unsigned char *p = manager.getBufferPointer() ;
                                    NSData *data = [NSData dataWithBytes:p length:sizeof(BaseNetworkPacket)] ;
                                    KDPacket *packet = [KDPacket deSerialization:data] ;
                                    unsigned int packetLen = packet.packet->header.length ;
                                    if (len < packetLen) {
                                        break ;
                                    }
                                    data = [NSData dataWithBytes:p length:packetLen] ;
                                    packet = [KDPacket deSerialization:data] ;
                                    manager.removeBuffer(packetLen) ;
                                    
                                    BaseNetworkPacket *basePacket = [packet packet] ;
                                    if (basePacket->header.cmd == Cmd_Text) {
                                        TextPacket *textpacket = (TextPacket *)basePacket ;
                                        textpacket->text[textpacket->textLen] = '\0' ;
                                        [_delegate dataReceived:packet] ;
                                    }
                                } else {
                                    break ;
                                }
                            }
                            if (r < 0) {
                                if (errno == EWOULDBLOCK) {
                                    // read would block but socket is set to nonblock
                                    continue ;
                                }
                                printf("read error %d\n", errno) ;
                                break ;
                            } else if (r == 0) {
                                printf("connection closed by peer\n") ;
                                break ;
                            }
                        } else {
                            b = FD_ISSET(clientSocket, &eSet) ;
                            if (b) {
                                printf("socket error %d\n", errno) ;
                                // error
                                break ;
                            }
                        }
                    }
                }
            }
        } else {
            printf("connect error %d\n", errno) ;
        }
        close(clientSocket) ;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.networkState = NetworkStateDisconnect ;
            [_delegate connectionDidDisconnect] ;
        }) ;
        printf("thread stoped \n") ;
    }
}

@end
