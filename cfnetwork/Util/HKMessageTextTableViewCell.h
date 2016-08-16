//
//  HKMessageTextTableViewCell.h
//  HouseKeeper
//
//  Created by KudoCC on 15/11/8.
//  Copyright © 2015年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface HKMessageTextTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *labelTime;

@property (nonatomic, strong) Message *message;

+ (CGSize)cellSizeForMessage:(Message *)message;

@end
