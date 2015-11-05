//
//  KSActivityIndicatorBallPulseAnimation.h
//  SCPullRefresh
//
//  Created by LiuYihan on 15/11/5.
//  Copyright © 2015年 Singro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSActivityIndicatorBallPulseAnimation : UIView

@property (nonatomic, assign) BOOL isLoadMore;

@property (nonatomic, assign) CGFloat timeOffset;  // 0.0 ~ 1.0

- (void)beginRefreshing;
- (void)endRefreshing;

@end
