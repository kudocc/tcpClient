//
//  KDSocketCFNetworkViewController.h
//  cfnetwork
//
//  Created by yuanrui on 14-8-14.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDSocketCFNetworkViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *labelNetworkState ;
@property (nonatomic, strong) IBOutlet UITextView *textViewSend ;
@property (nonatomic, strong) IBOutlet UITextView *textViewRecv ;

- (IBAction)sendMessage:(id)sender ;

@end
