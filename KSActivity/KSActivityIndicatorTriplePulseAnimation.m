//
//  KSActivityIndicatorTriplePulseAnimation.m
//  SCPullRefresh
//
//  Created by LiuYihan on 15/11/5.
//  Copyright © 2015年 Singro. All rights reserved.
//

#import "KSActivityIndicatorTriplePulseAnimation.h"

#define RGBA(c,a)    [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

static NSString *animationKey = @"animationKey";

@interface KSActivityIndicatorTriplePulseAnimation()

@property (nonatomic, strong) NSMutableArray   *circleArray;

@end

@implementation KSActivityIndicatorTriplePulseAnimation

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self){
        
        CGSize size = (CGSize){40,40};
        
        self.circleArray = [NSMutableArray new];
        
        NSTimeInterval beginTime = CACurrentMediaTime();
        
        CGFloat oX = (self.layer.bounds.size.width - size.width) / 2.0f;
        CGFloat oY = (self.layer.bounds.size.height - size.height) / 2.0f;
        for (int i = 0; i < 4; i++) {
            CALayer *circle = [CALayer layer];
            
            circle.frame = CGRectMake(oX, oY, size.width, size.height);
            circle.backgroundColor = RGBA(0x39C6D7,1.0).CGColor;
            circle.anchorPoint = CGPointMake(0.5f, 0.5f);
            circle.opacity = 0.8f;
            circle.cornerRadius = circle.bounds.size.height / 2.0f;
            circle.transform = CATransform3DMakeScale(0.0f, 0.0f, 0.0f);
            circle.speed = 0;
            circle.timeOffset = 0;
            
            CAAnimationGroup *groupAnimation = [self animationGroup:i beginTime:beginTime];
            groupAnimation.repeatCount = NSIntegerMax;
            groupAnimation.speed = 1;
            [circle addAnimation:groupAnimation forKey:animationKey];
            
            [self.circleArray addObject:circle];
            [self.layer addSublayer:circle];
        }
    }
    
    return self;
}

- (CAAnimationGroup *)animationGroup:(NSInteger)index beginTime:(NSTimeInterval)beginTime{
    
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0f, 0.0f, 0.0f)];
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 0.0f)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(0.8f);
    opacityAnimation.toValue = @(0.0f);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.removedOnCompletion = NO;
    animationGroup.beginTime = index / 1.0;
    animationGroup.repeatCount = HUGE_VALF;
    animationGroup.duration = 1.2f;
    animationGroup.animations = @[transformAnimation, opacityAnimation];
    animationGroup.timeOffset = 0;
    
    return animationGroup;
}

- (void)setTimeOffset:(CGFloat)timeOffset {
    
    _timeOffset = timeOffset;
    
    for (int i = 0; i < self.circleArray.count; i ++) {
        CALayer *animationLayer = self.circleArray[i];
        animationLayer.timeOffset = timeOffset * 2;
    }
    
}

- (void)beginRefreshing{
    
    for (int i = 0; i < self.circleArray.count; i ++) {
        CALayer *animationLayer = self.circleArray[i];
        animationLayer.speed = 1.0;
    
    }
}

- (void)endRefreshing{
    
    for (CALayer *layer in self.circleArray) {
        [layer removeAllAnimations];
    }
    
    for (int i = 0; i < self.circleArray.count; i ++) {
        CALayer *animationLayer = self.circleArray[i];
        animationLayer.speed = 0.0;
        animationLayer.repeatCount = 1;
        animationLayer.timeOffset = 0;
        
        CAAnimationGroup *animationGroup = [self animationGroup:i beginTime:CACurrentMediaTime()];
        animationGroup.speed = 1;
        animationGroup.repeatCount = NSIntegerMax;
        
        [animationLayer addAnimation:animationGroup forKey:animationKey];
    }
}

@end
