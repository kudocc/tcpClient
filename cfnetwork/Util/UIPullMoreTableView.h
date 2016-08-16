//
//  UIPullMoreTableView.h
//  UITest
//
//  Created by KudoCC on 15/11/20.
//  Copyright © 2015年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PullMoreTableViewLoadDataBlock)(void);

@interface UIPullMoreTableView : UITableView

/**
 *  需要加载更多数据的时候会回调
 */
@property (nonatomic, strong) PullMoreTableViewLoadDataBlock loadData;

/**
 *  default is NO
 */
@property (nonatomic, assign) BOOL showActivityIndicatorView;


- (void)finishLoading;

@end
