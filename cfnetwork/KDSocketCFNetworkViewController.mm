//
//  KDSocketCFNetworkViewController.m
//  cfnetwork
//
//  Created by KudoCC on 14-8-14.
//  Copyright (c) 2014年 KudoCC. All rights reserved.
//

#import "KDSocketCFNetworkViewController.h"
#import "KDNetworkUtility.h"
#import "KDPacket.h"
#import "PacketMemoryManager.h"
#import "NetworkHeader.h"
#import "KDCFNetworkConnection.h"

@interface KDSocketCFNetworkViewController () <ConnectionDelegate>

@property (nonatomic, strong) KDCFNetworkConnection *connection ;

@end

@implementation KDSocketCFNetworkViewController

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
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _connection = [[KDCFNetworkConnection alloc] initWithDelegate:self] ;
    [_connection connect] ;
    
    _textViewRecv.editable = NO ;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)] ;
    tap.numberOfTapsRequired = 2 ;
    [self.view addGestureRecognizer:tap] ;
}

- (void)doubleTap:(id)sender
{
    [_textViewSend resignFirstResponder] ;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated] ;
    self.title = @"TCP Client support VOIP" ;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [_connection closeConnection] ;
    }
    [super viewWillDisappear:animated] ;
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

- (IBAction)sendMessage:(id)sender
{
    NSString *strSend = _textViewSend.text ;
    NSData *dataSend = nil ;
    if ([strSend length] > 0) {
        dataSend = [strSend dataUsingEncoding:NSUTF8StringEncoding] ;
    }
    
    if ([dataSend length] > 0) {
        if ([_connection isConnect]) {
            TextPacket s_packet ;
            s_packet.setTransId([KDNetworkUtility generatorTransId]) ;
            s_packet.textLen = [dataSend length] ;
            memcpy(s_packet.text, dataSend.bytes, [dataSend length]) ;
            KDPacket *packet = [KDPacket serialization:&s_packet] ;
            [_connection sendData:packet] ;
        }
    }
    [_textViewSend resignFirstResponder] ;
}

- (void)presentLocalNotificationMessage:(NSString *)message
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif) {
        localNotif.fireDate = [NSDate date] ;
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        
        localNotif.alertBody = message ;
        localNotif.alertAction = @"view detail" ;
        
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif] ;
    }
}

#pragma mark - ConnectionDelegate

- (NSString *)ipAddress
{
    return @"172.16.40.62" ;
}

- (uint16_t)port
{
    return (uint16_t)70001 ;
}

- (void)dataReceived:(KDPacket *)packet
{
    BaseNetworkPacket *basePacket = [packet packet] ;
    if (basePacket->header.cmd == Cmd_Text) {
        TextPacket *textpacket = (TextPacket *)basePacket ;
        textpacket->text[textpacket->textLen] = '\0' ;
        NSString *str = [NSString stringWithUTF8String:(const char *)textpacket->text] ;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                [self presentLocalNotificationMessage:str] ;
            }
            _textViewRecv.text = str ;
        }) ;
    }
}

- (void)connectionDidConnect
{
    _labelNetworkState.text = @"CONNECTED" ;
}

- (void)connectionDidDisconnect
{
    _labelNetworkState.text = @"DISCONNECT" ;
}

- (void)connectionFailWithError:(int)error
{
    _labelNetworkState.text = @"DISCONNECT" ;
}

@end
