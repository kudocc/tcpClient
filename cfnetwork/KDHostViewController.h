//
//  KDHostViewController.h
//  cfnetwork
//
//  Created by KudoCC on 14-7-16.
//  Copyright (c) 2014年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KDHostViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *textField ;
@property (nonatomic, strong) IBOutlet UITextView *textView ;

- (IBAction)doResolveDNS:(id)sender ;

@end
