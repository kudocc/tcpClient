//
//  KDHttpsViewController.m
//  cfnetwork
//
//  Created by yuanrui on 14-8-4.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#import "KDHttpsViewController.h"

@interface KDHttpsViewController ()

@end

@implementation KDHttpsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *strUrl = @"https://kyfw.12306.cn/otn/leftTicket/init" ;
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0] ;
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES] ;
    if (!connection) {
        NSLog(@"http start error") ;
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

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), error) ;
}

//- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;
//- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES ;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSData *certData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"srca" ofType:@"cer"]];
        SecCertificateRef rootcert = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)(certData)) ;
        const void *array[1] = { rootcert } ;
        CFArrayRef certs = CFArrayCreate(NULL, array, 1, &kCFTypeArrayCallBacks) ;
        CFRelease(rootcert) ;
        
        SecTrustRef trust = [[challenge protectionSpace] serverTrust] ;
        int err = 0 ;
        SecTrustResultType trustResult = 0;
        err = SecTrustSetAnchorCertificates(trust, certs) ;
        if (err == noErr) {
            err = SecTrustEvaluate(trust, &trustResult) ;
        }
        CFRelease(trust) ;
        CFRelease(certs) ;
        BOOL trusted = (err == noErr) && (trustResult == kSecTrustResultProceed ||
                                          trustResult == kSecTrustResultConfirm ||
                                          trustResult == kSecTrustResultUnspecified) ;
        
        if (trusted) {
            [challenge.sender useCredential:
             [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
                 forAuthenticationChallenge:challenge] ;
        } else {
            [challenge.sender cancelAuthenticationChallenge:challenge] ;
        }
    }
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), response) ;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%@, %lu", NSStringFromSelector(_cmd), (unsigned long)[data length]) ;
}

@end
