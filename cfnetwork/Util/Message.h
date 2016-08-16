//
//  Message.h
//  cfnetwork
//
//  Created by KudoCC on 16/8/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (nonatomic) BOOL peer;
@property (nonatomic) NSString *text;
@property (nonatomic) NSDate *date;

@end