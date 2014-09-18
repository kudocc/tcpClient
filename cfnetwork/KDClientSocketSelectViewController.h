//
//  KDClientSocketSelectViewController.h
//  cfnetwork
//
//  Created by KudoCC on 14-7-21.
//  Copyright (c) 2014年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDClientSocketSelectViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *labelNetworkState ;
@property (nonatomic, strong) IBOutlet UITextView *textViewSend ;
@property (nonatomic, strong) IBOutlet UITextView *textViewRecv ;

- (IBAction)sendMessage:(id)sender ;

@end
