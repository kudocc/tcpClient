//
//  UIColor+Util.h
//  HouseKeeper
//
//  Created by KudoCC on 15/11/7.
//  Copyright © 2015年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Util)

+ (UIColor *)opaqueColorWithHexString:(NSString *)stringToConvert;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha;

@end
