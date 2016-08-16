//
//  HKAutoresizeTextView.m
//  HouseKeeper
//
//  Created by KudoCC on 15/11/8.
//  Copyright © 2015年 KudoCC. All rights reserved.
//

#import "HKAutoresizeTextView.h"

@implementation HKAutoresizeTextView

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentSize"];
}

- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        NSValue *value = [change objectForKey:NSKeyValueChangeNewKey];
        CGRect frame = self.frame;
        frame.size = [value CGSizeValue];
        if (frame.size.height <= _maxHeight) {
            [UIView animateWithDuration:0.2 animations:^{
                self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            }];
        } else {
            [self setContentOffset:CGPointMake(0.0, frame.size.height - self.frame.size.height) animated:NO];
        }
    }
}


@end
