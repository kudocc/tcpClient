//
//  UIDevice+Network.m
//  cfnetwork
//
//  Created by KudoCC on 14-8-27.
//  Copyright (c) 2014年 KudoCC. All rights reserved.
//

#import "UIDevice+Network.h"
//#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>

@implementation UIDevice (Network)

+ (NSString *)descriptionOfSCNetworkReachabilityFlag:(SCNetworkReachabilityFlags)flags
{
    NSMutableString *mString = [NSMutableString string] ;
    
    NSLog(@"reachability flags %u", flags) ;
    if (flags & kSCNetworkReachabilityFlagsTransientConnection) {
        [mString appendString:@"kSCNetworkReachabilityFlagsTransientConnection\n"] ;
    }
    if (flags & kSCNetworkReachabilityFlagsReachable) {
        [mString appendString:@"kSCNetworkReachabilityFlagsReachable\n"] ;
    }
    if (flags & kSCNetworkReachabilityFlagsConnectionRequired) {
        [mString appendString:@"kSCNetworkReachabilityFlagsConnectionRequired\n"] ;
    }
    if (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) {
        [mString appendString:@"kSCNetworkReachabilityFlagsConnectionOnTraffic\n"] ;
    }
    if (flags & kSCNetworkReachabilityFlagsInterventionRequired) {
        [mString appendString:@"kSCNetworkReachabilityFlagsInterventionRequired\n"] ;
    }
    if (flags & kSCNetworkReachabilityFlagsConnectionOnDemand) {
        [mString appendString:@"kSCNetworkReachabilityFlagsConnectionOnDemand\n"] ;
    }
    if (flags & kSCNetworkReachabilityFlagsIsLocalAddress) {
        [mString appendString:@"kSCNetworkReachabilityFlagsIsLocalAddress\n"] ;
    }
    if (flags & kSCNetworkReachabilityFlagsIsDirect) {
        [mString appendString:@"kSCNetworkReachabilityFlagsIsDirect\n"] ;
    }
    if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
        [mString appendString:@"kSCNetworkReachabilityFlagsIsWWAN"] ;
    }
    if ([mString length] == 0) {
        [mString appendString:@"flags is zero"] ;
    }
    return mString ;
}

- (NSString *)localIp
{
    char buf[256] = {} ;
    if(gethostname(buf,sizeof(buf)))
        return nil;
    struct hostent* he = gethostbyname(buf);
    if(!he)
        return nil;
    for(int i=0; he->h_addr_list[i]; i++) {
        char* ip = inet_ntoa(*(struct in_addr*)he->h_addr_list[i]);
        if(ip != (char*)-1) {
            NSString *strIp = [NSString stringWithUTF8String:ip] ;
            return strIp ;
        }
    }
    return NULL;
}

@end
