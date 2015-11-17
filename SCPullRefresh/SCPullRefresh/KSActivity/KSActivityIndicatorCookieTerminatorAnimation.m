//
//  KSActivityIndicatorCookieTerminatorAnimation.m
//  SCPullRefresh
//
//  Created by LiuYihan on 15/11/5.
//  Copyright © 2015年 Singro. All rights reserved.
//

#import "KSActivityIndicatorCookieTerminatorAnimation.h"

#import "CAAnimation+Blocks.h"

#define RGBA(c,a)    [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

static NSString *animationKey = @"animationKey";

static CGFloat  cookieAnimationTime = 1.8f;
static CGFloat  jawAnimationTime = 0.3f;

@interface KSActivityIndicatorCookieTerminatorAnimation()

@property (nonatomic, assign) CGSize                            defaultSize;
@property (nonatomic, strong) NSArray<UIColor *>                *colorArray;

@property (nonatomic, strong) CAShapeLayer                      *cookieTerminatorLayer;
@property (nonatomic, strong) NSMutableArray<CAShapeLayer *>    *jawLayerArray;
@property (nonatomic, strong) NSMutableArray<CALayer *>         *cookieLayerArray;

@property (nonatomic, strong) UIBezierPath                      *path;

@property (nonatomic, assign) CGFloat                           cookieSize;
@property (nonatomic, assign) CGFloat                           cookiePadding;

@property (nonatomic, strong) NSTimer                           *timer;
@property (nonatomic, assign) NSInteger                         indexNow;

@end

@implementation KSActivityIndicatorCookieTerminatorAnimation

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self){
        
        self.defaultSize = (CGSize){40,40};
        self.colorArray = @[RGBA(0x39c6d7, 1.0),RGBA(0xff6700,1.0),RGBA(0xffdb08, 1.0)];
        
        self.jawLayerArray = [NSMutableArray new];
        self.cookieLayerArray = [NSMutableArray new];
        
        self.timer = [[NSTimer alloc] init];
        [self.timer invalidate];
        
        CGFloat cookieTerminatorSize =  ceilf(self.defaultSize.width / 3.0f);
        CGFloat oX = (self.layer.bounds.size.width - self.defaultSize.width) / 2.0f;
        CGFloat oY = self.layer.bounds.size.height / 2.0f;
        CGPoint cookieTerminatorCenter = CGPointMake(oX, oY);
        
        self.path = [UIBezierPath bezierPathWithArcCenter:cookieTerminatorCenter radius:cookieTerminatorSize startAngle:M_PI_4 endAngle:M_PI * 1.75f clockwise:YES];
        [self.path addLineToPoint:cookieTerminatorCenter];
        [self.path closePath];
        
        self.cookieTerminatorLayer = [CAShapeLayer layer];
        self.cookieTerminatorLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
        self.cookieTerminatorLayer.fillColor = [UIColor whiteColor].CGColor;
        self.cookieTerminatorLayer.path = self.path.CGPath;
        [self.layer addSublayer:self.cookieTerminatorLayer];
        
        self.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0.0f, 0.0f) radius:cookieTerminatorSize startAngle:M_PI_2 endAngle:M_PI * 1.5f clockwise:YES];
        [self.path closePath];
        
        for (int i = 0; i < 2; i++) {
            CAShapeLayer *jawLayer = [CAShapeLayer layer];
            jawLayer.path = self.path.CGPath;
            jawLayer.position = cookieTerminatorCenter;
            jawLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
            jawLayer.opacity = 1.0f;
            jawLayer.transform = CATransform3DMakeRotation((1.0f - 2.0f * i) * M_PI_4, 0.0f, 0.0f, 1.0f);
            jawLayer.fillColor = RGBA(0x39c6d7, 1.0).CGColor;
            jawLayer.speed = 0;
            
            CABasicAnimation *transformAnimation = [self jawAnimation:i];
            transformAnimation.timeOffset = 0;
            
            [self.layer addSublayer:jawLayer];
            [self.jawLayerArray addObject:jawLayer];
            
            [jawLayer addAnimation:transformAnimation forKey:animationKey];
        }
        
        CAShapeLayer *firstJawLayer = [self.jawLayerArray firstObject];
        
        self.cookieSize = ceilf(self.defaultSize.width / 6.0f);
        self.cookiePadding = self.cookieSize * 2.0f;
        
        for (int i = 0; i < 3; i++) {
            
            CALayer *cookieLayer = [CALayer layer];
            cookieLayer.frame = CGRectMake(cookieTerminatorCenter.x + (self.cookieSize + self.cookiePadding) * 3.0f - cookieTerminatorSize, oY - self.cookieSize / 2.0f, self.cookieSize, self.cookieSize);
            UIColor *cookieColor = [self.colorArray objectAtIndex:i];
            cookieLayer.backgroundColor = cookieColor.CGColor;
            cookieLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
            cookieLayer.opacity = 1.0f;
            cookieLayer.cornerRadius = self.cookieSize / 2.0f;
            cookieLayer.speed = 0;
            
            CABasicAnimation *transformAnimation = [self cookieAnimation:i];
            transformAnimation.timeOffset = 0;
            
            [self.layer insertSublayer:cookieLayer below:firstJawLayer];
            [self.cookieLayerArray addObject:cookieLayer];
            [cookieLayer addAnimation:transformAnimation forKey:animationKey];
        }
        
    }
    
    return self;
}

- (CABasicAnimation *)jawAnimation:(NSInteger)index{
    
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.beginTime = 0;
    transformAnimation.duration = jawAnimationTime;
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation((1.0f - 2.0f * index) * M_PI_4, 0.0f, 0.0f, 1.0f)];
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation((1.0f - 2.0f * index) * M_PI_2, 0.0f, 0.0f, 1.0f)];
    transformAnimation.autoreverses = YES;
    transformAnimation.repeatCount = HUGE_VALF;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    
    return transformAnimation;
}

- (CABasicAnimation *)cookieAnimation:(NSInteger)index{
    
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.duration = cookieAnimationTime;
    transformAnimation.beginTime = 0 - (index * transformAnimation.duration / 3.0f);
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, 0.0f, 0.0f)];
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-3.0f * (self.cookieSize + self.cookiePadding), 0.0f, 0.0f)];
    transformAnimation.repeatCount = HUGE_VALF;
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
    
    return transformAnimation;
}

- (void)setTimeOffset:(CGFloat)timeOffset {
    
    _timeOffset = timeOffset;
    
    for (CAShapeLayer *jawLayer in self.jawLayerArray) {
        jawLayer.timeOffset = timeOffset;
    }
    
    for (CALayer *cookieLayer in self.cookieLayerArray) {
        cookieLayer.timeOffset = timeOffset;
    }
    
    
    if (timeOffset > 0.001){
        
        NSInteger preIndex = timeOffset * 10;
        NSInteger index = preIndex / 6 % self.colorArray.count;
        index = self.colorArray.count - index - 1;
        
        UIColor *color = [self.colorArray objectAtIndex:index];
        
        for (CAShapeLayer *jawLayer in self.jawLayerArray) {
            jawLayer.fillColor = color.CGColor;
        }
    }
}

- (void)animateLoop{
    
    UIColor *color = [self.colorArray objectAtIndex:self.indexNow];
    for (CAShapeLayer *jawLayer in self.jawLayerArray) {
        jawLayer.fillColor = color.CGColor;
    }
    
    self.indexNow -= 1;
    
    if (self.indexNow == -1){
        self.indexNow = self.colorArray.count - 1;
    }
}

- (void)beginRefreshing{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
        
        self.indexNow = 2;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(animateLoop) userInfo:nil repeats:YES];
    });
    
    for (CAShapeLayer *jawLayer in self.jawLayerArray) {
        jawLayer.speed = 1.0;
        jawLayer.timeOffset = 0;
        jawLayer.fillColor = RGBA(0x39c6d7, 1.0).CGColor;
    }
    
    for (CALayer *cookieLayer in self.cookieLayerArray) {
        cookieLayer.speed = 1.0;
        cookieLayer.timeOffset = 0;
    }
    
}

- (void)endRefreshing{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.40 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
        
        [self.timer invalidate];
        self.indexNow = 2;
        
        for (int i = 0; i < self.jawLayerArray.count ; i++) {
            CAShapeLayer *jawLayer = [self.jawLayerArray objectAtIndex:i];
            jawLayer.speed = 0;
            jawLayer.fillColor = RGBA(0x39c6d7, 1.0).CGColor;
            
            [jawLayer removeAllAnimations];
            
            CABasicAnimation *transformAnimation = [self jawAnimation:i];
            transformAnimation.timeOffset = 0;
            [jawLayer addAnimation:transformAnimation forKey:animationKey];
        }
        
        for ( int i = 0; i < self.cookieLayerArray.count; i++) {
            CALayer *cookieLayer = [self.cookieLayerArray objectAtIndex:i];
            cookieLayer.speed = 0;
            
            [cookieLayer removeAllAnimations];
            
            CABasicAnimation *transformAnimation = [self cookieAnimation:i];
            transformAnimation.timeOffset = 0;
            [cookieLayer addAnimation:transformAnimation forKey:animationKey];
        }
        
        self.timeOffset = 0.0f;
    });
}
@end
