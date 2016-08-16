//
//  UIPullMoreTableView.m
//  UITest
//
//  Created by KudoCC on 15/11/20.
//  Copyright © 2015年 KudoCC. All rights reserved.
//

#import "UIPullMoreTableView.h"

@interface UIPullMoreTableView ()

@property (nonatomic, strong) UIView *viewFooter;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation UIPullMoreTableView

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentSize"];
    
    if (_indicatorView) {
        [self removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
//        CGSize contentSize = [change[NSKeyValueChangeNewKey] CGSizeValue];
//        CGFloat height = self.bounds.size.height;
//        if (contentSize.height > height - self.contentInset.top) {
//            [self showActivityIndicator];
//        }
    } else if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        if (_indicatorView && !_indicatorView.isAnimating) {
            if (offset.y < -(self.contentInset.top - _viewFooter.bounds.size.height)) {
                [_indicatorView startAnimating];
                if (_loadData) {
                    _loadData();
                }
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)showActivityIndicator {
    if (_indicatorView) {
        return;
    }
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _viewFooter = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, 32.0)];
    [_viewFooter addSubview:_indicatorView];
    _indicatorView.center = CGPointMake(_viewFooter.bounds.size.width/2, _viewFooter.bounds.size.height/2);
    self.tableHeaderView = _viewFooter;
    
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)hideActivityIndicator {
    if (_indicatorView) {
        self.tableHeaderView = nil;
        _indicatorView = nil;
        
        [self removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (void)setShowActivityIndicatorView:(BOOL)showActivityIndicatorView {
    _showActivityIndicatorView = showActivityIndicatorView;
    
    if (_showActivityIndicatorView) {
        [self showActivityIndicator];
    } else {
        [self hideActivityIndicator];
    }
}

- (void)finishLoading {
    if (_indicatorView && _indicatorView.isAnimating) {
        [_indicatorView stopAnimating];
    }
}

@end
