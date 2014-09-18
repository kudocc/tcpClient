//
//  KDAppDelegate.m
//  cfnetwork
//
//  Created by yuanrui on 14-7-16.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#import "KDAppDelegate.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@implementation TestObj

- (BOOL)isEqual:(id)object
{
    return YES ;
}

- (NSUInteger)hash
{
    return 10 ;
}

@end

@implementation KDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    TestObj *obj1 = [[TestObj alloc] init] ;
    obj1.value = 2 ;
    TestObj *obj2 = [[TestObj alloc] init] ;
    obj2.value = 1 ;
    NSLog(@"obj1 addr:%p, obj2 addr:%p", obj1, obj2) ;
    NSLog(@"%u, obj1 hash:%lu, obj2 hash:%lu", [obj1 isEqual:obj2], (unsigned long)[obj1 hash], (unsigned long)[obj2 hash]) ;
    
    NSArray *array1 = @[obj1, obj2] ;
    NSArray *array2 = @[obj2, obj1] ;
    NSLog(@"%@, %@", @([array1 indexOfObject:obj2]), @([array2 indexOfObject:obj2])) ;
    
    int radius = 10 ;
    NSString *strNumber = @"3.1415926" ;
    float pia = [strNumber floatValue] ;
    NSLog(@"pia is %f, the length of circle is %f", pia, 2*pia*radius) ;
    NSDecimalNumber *numPia = [[NSDecimalNumber alloc] initWithString:strNumber] ;
    NSLog(@"pia is %@, the length of circle is %@", numPia, [numPia decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithString:@"20"]]) ;
    
    // Override point for customization after application launch.
    /*
    int clientSocket = socket(AF_INET, SOCK_STREAM, 0) ;
    struct sockaddr_in server_addr ;
    bzero(&server_addr, sizeof(server_addr)) ;
    server_addr.sin_port = htons(53) ;
    server_addr.sin_addr.s_addr = inet_addr("8.8.8.8") ;
    server_addr.sin_family = AF_INET ;
    
    int i = connect(clientSocket, (const struct sockaddr *)&server_addr, sizeof(server_addr)) ;
    if (i >= 0) {
        NSLog(@"connected") ;
    }
    close(clientSocket) ;
    */

    /*
    CFStringRef originalURLString = CFSTR("http://online.store.com/storefront/?request=get-document&doi=10.1175%2F1520-0426(2005)014%3C1157:DODADSS%3E2.0.CO%3B2");
    CFStringRef preprocessedString =
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, originalURLString, CFSTR(""), kCFStringEncodingUTF8);
    NSString *preStr = (__bridge NSString *)preprocessedString ;
    NSLog(@"pre %@", preStr) ;
    CFStringRef urlString =
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, preprocessedString, NULL, NULL, kCFStringEncodingUTF8);
    NSString *str = (__bridge NSString *)urlString ;
    NSLog(@"%@", str) ;
     */
    
    NSString *param = @"hello 1/2.0 & 苑睿" ;
    param = [param stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    NSLog(@"%@", param) ;
    CFStringRef cfParam = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)param, NULL, CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8) ;
    param = (__bridge NSString *)cfParam ;
    NSString *strUrl = [NSString stringWithFormat:@"http://www.baidu.com/?a=%@", param] ;
    NSLog(@"%@", strUrl) ;
    CFRelease(cfParam) ;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"] ;
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]] ;
    NSDate *date = [NSDate date] ;
    NSLog(@"%@", date) ;
    NSLog(@"%@", [dateFormatter stringFromDate:date]) ;
    
    {
        CFMutableStringRef str = CFStringCreateMutableCopy(NULL, 1000, CFSTR("Hello World") );
        __strong NSMutableString *value = CFBridgingRelease(str) ;//(__bridge_transfer NSMutableString *)str ;
        
        
        [value appendString:@"hi"] ;
        NSLog(@"%@", value) ;
    }
    
//    NSDate *itemDate = [NSDate dateWithTimeIntervalSinceNow:20] ;
//    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//    if (localNotif) {
//        localNotif.fireDate = itemDate ;
//        localNotif.timeZone = [NSTimeZone defaultTimeZone];
//        
//        localNotif.alertBody = @"message" ;
//        localNotif.alertAction = @"view detail" ;
//        
//        localNotif.soundName = UILocalNotificationDefaultSoundName;
//        localNotif.applicationIconBadgeNumber = 1;
//        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
//    }
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"] ;
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
    NSTimeInterval timestamp = 683258400 ;
    NSDate* date1 = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSLog(@"%@", date1) ;
    NSString *str = [dateFormat stringFromDate:date1] ;
    NSLog(@"%@", str) ;
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), notification) ;
}

@end
