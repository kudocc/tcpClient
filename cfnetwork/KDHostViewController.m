//
//  KDHostViewController.m
//  cfnetwork
//
//  Created by KudoCC on 14-7-16.
//  Copyright (c) 2014年 KudoCC. All rights reserved.
//

#import "KDHostViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>
#import "UIDevice+Network.h"

void myhostClientCallback(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info) ;

@interface KDHostViewController ()
{
    SCNetworkReachabilityRef reachabilityRef ;
}

@end

void callback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
    NSString *localIp = [[UIDevice currentDevice] localIp] ;
    
    NSLog(@"ip:%@\n%@", localIp, [UIDevice descriptionOfSCNetworkReachabilityFlag:flags]) ;
}

@implementation KDHostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    if (reachabilityRef) {
        NSLog(@"reachability released") ;
        SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode) ;
        CFRelease(reachabilityRef) ;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    struct sockaddr_in addr ;
    unsigned int u_addr ;
    int res = inet_net_pton(AF_INET, "192.168.18.1", &u_addr, sizeof(u_addr)) ;
    if (res != -1) {
        addr.sin_len = sizeof(addr) ;
        addr.sin_addr.s_addr = u_addr ;
        addr.sin_family = AF_INET ;
        reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (const struct sockaddr *)&addr) ;
//        reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, "www.baidu.com") ;
        SCNetworkReachabilityContext context = {
            0, (__bridge void *)(self), NULL, NULL, NULL
        } ;
        
        if (SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context)) {
            if (SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode) ) {
                NSLog(@"create and config reachability sucess") ;
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doResolveDNS:(id)sender
{
    NSString *string = _textField.text ;
    if ([string length] > 0) {
        CFStringRef name = (__bridge CFStringRef)(string) ;
        CFHostRef host = CFHostCreateWithName(kCFAllocatorDefault, name) ;
        if (host) {
            CFHostClientContext context ;
            memset(&context, 0, sizeof(context)) ;
            context.info = (__bridge void *)self ;
            CFHostSetClient(host, myhostClientCallback, &context) ;
            CFHostScheduleWithRunLoop(host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode) ;
            
            BOOL result = CFHostStartInfoResolution(host, kCFHostAddresses, NULL) ;
            NSAssert(result, @"start error") ;
        }
    }
}

#pragma mark - CFHost

void myhostClientCallback(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info)
{
    @autoreleasepool {
        if (error->error && error->domain) {
            NSLog(@"error %d", (int)error->error) ;
            return ;
        }
        KDHostViewController *vc = (__bridge KDHostViewController *)info ;
        Boolean hasBeenResolved = false ;
        CFArrayRef array = CFHostGetAddressing(theHost, &hasBeenResolved) ;
        NSLog(@"host info type %u, resolved:%u", typeInfo, hasBeenResolved) ;
        CFIndex count = CFArrayGetCount(array) ;
        NSMutableString *mString = [NSMutableString string] ;
        for (CFIndex i = 0; i < count; ++i) {
            CFDataRef dataRef = CFArrayGetValueAtIndex(array, i) ;
            NSData *data = (__bridge NSData *)dataRef ;
//            const struct sockaddr_in *p = (const struct sockaddr_in *)data.bytes ;
//            const char *addr = inet_ntoa(p->sin_addr) ;
//            NSLog(@"%s", addr) ;
//            NSLog(@"%@, %u", data, p->sin_len) ;
            char buffer[NI_MAXHOST] = {0} ;
            int gai_error = getnameinfo(data.bytes,
                                        (socklen_t)data.length,
                                        buffer, NI_MAXHOST, NULL, 0, NI_NUMERICHOST) ;
            if (gai_error) {
                break ;
            }
            NSString *str = [NSString stringWithUTF8String:buffer] ;
            NSLog(@"ip address:%@", str) ;
            [mString appendString:str] ;
            [mString appendString:@"\n"] ;
        }
        vc.textView.text = mString ;
        
        CFHostSetClient(theHost, NULL, NULL) ;
        CFHostUnscheduleFromRunLoop(theHost, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode) ;
        CFRelease(theHost) ;
    }
}

#pragma mark - SCNetworkReachability


@end
