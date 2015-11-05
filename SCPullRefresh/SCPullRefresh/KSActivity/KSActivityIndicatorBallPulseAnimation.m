//
//  KSActivityIndicatorBallPulseAnimation.m
//  SCPullRefresh
//
//  Created by LiuYihan on 15/11/5.
//  Copyright © 2015年 Singro. All rights reserved.
//

#import "KSActivityIndicatorBallPulseAnimation.h"

#import "CAAnimation+Blocks.h"

#define RGBA(c,a)    [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

static NSString *const kInitAnimation = @"InitAnimation";
static NSString *const kGroupAnimation = @"GroupAnimation";

static CGFloat kDGActivityIndicatorDefaultSize = 10.0f;
static CGFloat duration = 0.75f;

@interface KSActivityIndicatorBallPulseAnimation()

@property (nonatomic, strong) NSMutableArray    *layerArray;
@property (nonatomic, strong) NSArray           *timeArray;
@property (nonatomic, strong) NSArray           *colorArray;

@end

@implementation KSActivityIndicatorBallPulseAnimation

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self){
        
        self.timeArray = @[@0.12f, @0.24f, @0.36f];
        self.colorArray = @[[UIColor redColor],[UIColor blueColor],[UIColor orangeColor]];
        
        CGFloat circlePadding = 8.0f;
        CGFloat circleSize = kDGActivityIndicatorDefaultSize;
        CGFloat x = self.layer.bounds.size.width / 2- kDGActivityIndicatorDefaultSize * 3  / 2 - circlePadding;
        CGFloat y = (self.layer.bounds.size.height - circleSize) / 2;
        
        self.layerArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 3; i++) {
            CALayer *circle = [CALayer layer];
            
            circle.frame = (CGRect){x + i * circleSize + i * circlePadding, y, circleSize, circleSize};
            circle.backgroundColor = RGBA(0x39C6D7,1.0).CGColor;
            circle.cornerRadius = circle.bounds.size.width / 2;
            circle.speed = 0.0;
            circle.opaque = 0.5f;
            circle.repeatCount = 1;
            circle.timeOffset = 0;
            
            CAAnimation *animation = [self createAnimation];
            animation.speed = 1;
            animation.repeatCount = NSIntegerMax;
            animation.beginTime = [self.timeArray[i] floatValue];
            
            [circle addAnimation:animation forKey:kInitAnimation];
            [self.layer addSublayer:circle];
            [self.layerArray addObject:circle];
        }
        
    }
    
    return self;
}

- (CAAnimation *)createAnimation{
    
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.2f :0.68f :0.18f :1.08f];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.3f, 0.3f, 1.0f)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)]];
    animation.keyTimes = @[@0.0f, @0.3f, @1.0f];
    animation.timingFunctions = @[timingFunction, timingFunction];
    animation.duration = duration;
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = NO;
    
    return animation;
}

#pragma mark - Public Methods

- (void)setTimeOffset:(CGFloat)timeOffset {
    
    _timeOffset = timeOffset;
    
    for (int i = 0; i < self.layerArray.count; i ++) {
        CALayer *animationLayer = self.layerArray[i];
        animationLayer.timeOffset = timeOffset;
    }
    
}


- (void)beginRefreshing{
    
    [self beginAnimation];
}

- (void)endRefreshing{
    
    [self endAnimation];
}

- (void)beginAnimation {
    
    for (int i = 0; i < self.layerArray.count; i ++) {
        CALayer *animationLayer = self.layerArray[i];
        animationLayer.speed = 1.0;
        
        animationLayer.repeatCount = 1;
        animationLayer.timeOffset = 0;
        
        CAAnimation *animationGroup = [self createAnimation];
        animationGroup.speed = 1;
        animationGroup.repeatCount = NSIntegerMax;
        animationGroup.beginTime = [self.timeArray[i] floatValue];
        
        [animationLayer addAnimation:animationGroup forKey:kInitAnimation];
    }
    
}

- (void)endAnimation {
    
    for (CALayer *layer in self.layerArray) {
        [layer removeAllAnimations];
    }

}


@end
