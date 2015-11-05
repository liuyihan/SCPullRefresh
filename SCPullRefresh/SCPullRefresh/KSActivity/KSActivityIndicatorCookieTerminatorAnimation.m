//
//  KSActivityIndicatorCookieTerminatorAnimation.m
//  SCPullRefresh
//
//  Created by LiuYihan on 15/11/5.
//  Copyright © 2015年 Singro. All rights reserved.
//

#import "KSActivityIndicatorCookieTerminatorAnimation.h"

#define RGBA(c,a)    [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

static NSString *animationKey = @"animationKey";

@interface KSActivityIndicatorCookieTerminatorAnimation()

@property (nonatomic, assign) CGSize defaultSize;

@property (nonatomic, strong) NSMutableArray *jwArray;
@property (nonatomic, strong) NSMutableArray *cookieArray;

@end

@implementation KSActivityIndicatorCookieTerminatorAnimation

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self){
        
        self.defaultSize = (CGSize){40,40};
        
        NSTimeInterval beginTime = CACurrentMediaTime();
        
        CGFloat cookieTerminatorSize =  ceilf(self.defaultSize.width / 3.0f);
        CGFloat oX = (self.layer.bounds.size.width - self.defaultSize.width) / 2.0f;
        CGFloat oY = self.layer.bounds.size.height / 2.0f;
        CGPoint cookieTerminatorCenter = CGPointMake(oX, oY);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:cookieTerminatorCenter radius:cookieTerminatorSize startAngle:M_PI_4 endAngle:M_PI * 1.75f clockwise:YES];
        [path addLineToPoint:cookieTerminatorCenter];
        [path closePath];
        
        CAShapeLayer *cookieTerminatorLayer = [CAShapeLayer layer];
        cookieTerminatorLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
        cookieTerminatorLayer.fillColor = RGBA(0x39C6D7,1.0).CGColor;
        cookieTerminatorLayer.path = path.CGPath;
        [self.layer addSublayer:cookieTerminatorLayer];
        
        path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0.0f, 0.0f) radius:cookieTerminatorSize startAngle:M_PI_2 endAngle:M_PI * 1.5f clockwise:YES];
        [path closePath];
        for (int i = 0; i < 2; i++) {
            CAShapeLayer *jawLayer = [CAShapeLayer layer];
            jawLayer.path = path.CGPath;
            jawLayer.fillColor = RGBA(0x39C6D7,1.0).CGColor;
            jawLayer.position = cookieTerminatorCenter;
            jawLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
            jawLayer.opacity = 1.0f;
            jawLayer.transform = CATransform3DMakeRotation((1.0f - 2.0f * i) * M_PI_4, 0.0f, 0.0f, 1.0f);
            
            CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            transformAnimation.removedOnCompletion = NO;
            transformAnimation.beginTime = beginTime;
            transformAnimation.duration = 0.3f;
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation((1.0f - 2.0f * i) * M_PI_4, 0.0f, 0.0f, 1.0f)];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation((1.0f - 2.0f * i) * M_PI_2, 0.0f, 0.0f, 1.0f)];
            transformAnimation.autoreverses = YES;
            transformAnimation.repeatCount = HUGE_VALF;
            transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
            
            [self.layer addSublayer:jawLayer];
            [jawLayer addAnimation:transformAnimation forKey:animationKey];
        }
        
        CGFloat cookieSize = ceilf(self.defaultSize.width / 6.0f);
        CGFloat cookiePadding = cookieSize * 2.0f;
        for (int i = 0; i < 3; i++) {
            CALayer *cookieLayer = [CALayer layer];
            cookieLayer.frame = CGRectMake(cookieTerminatorCenter.x + (cookieSize + cookiePadding) * 3.0f - cookieTerminatorSize, oY - cookieSize / 2.0f, cookieSize, cookieSize);
            cookieLayer.backgroundColor = RGBA(0x39C6D7,1.0).CGColor;
            cookieLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
            cookieLayer.opacity = 1.0f;
            cookieLayer.cornerRadius = cookieSize / 2.0f;
            
            CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            transformAnimation.duration = 1.8f;
            transformAnimation.beginTime = beginTime - (i * transformAnimation.duration / 3.0f);
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, 0.0f, 0.0f)];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-3.0f * (cookieSize + cookiePadding), 0.0f, 0.0f)];
            transformAnimation.repeatCount = HUGE_VALF;
            transformAnimation.removedOnCompletion = NO;
            transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
            
            [self.layer addSublayer:cookieLayer];
            [cookieLayer addAnimation:transformAnimation forKey:animationKey];
        }
        
    }
    
    return self;
}

- (void)beginRefreshing{
    
}

- (void)endRefreshing{
    
}

@end
