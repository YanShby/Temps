//
//  RotatedView.m
//  YanTemps
//
//  Created by Yans on 2016/11/30.
//  Copyright © 2016年 Yans. All rights reserved.
//

#import "YTRotatedView.h"

@interface YTRotatedView () <CAAnimationDelegate>

@end

@implementation YTRotatedView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    _hiddenAfterAnimation = NO;
}

- (void)addBackViewHeight:(CGFloat)height color:(UIColor *)color {
    
    YTRotatedView *view = [[YTRotatedView alloc]initWithFrame:CGRectZero];
    view.backgroundColor = color;
    view.layer.anchorPoint = CGPointMake(0.5,1);
    view.layer.transform = [self transform3d];
    view.translatesAutoresizingMaskIntoConstraints = false;
    
    [self addSubview:view];
    _backView = view;
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0
                                                      constant:height]];
    
    NSLayoutConstraint *t1=[NSLayoutConstraint constraintWithItem:view
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:self.bounds.size.height - height + height/2];
    NSLayoutConstraint *t2=[NSLayoutConstraint constraintWithItem:view
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:0];
    NSLayoutConstraint *t3=[NSLayoutConstraint constraintWithItem:view
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:0];
    YTLog(@"%@---%@---%@----",t1,t2,t3);
    [self addConstraints:@[t1,t2,t3]];
    
}

- (void)rotatedX:(CGFloat)angle {
    
    CATransform3D allTransofrom = CATransform3DIdentity;
    CATransform3D rotateTransform = CATransform3DMakeRotation(angle, 1, 0, 0);
    allTransofrom = CATransform3DConcat(allTransofrom, rotateTransform);
    allTransofrom = CATransform3DConcat(allTransofrom, [self transform3d]);
    self.layer.transform = allTransofrom;
}

- (CATransform3D)transform3d {
   
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 2.5 / -2000;
   
    return transform;
}

- (void)foldingAnimation:(NSString *)timing from:(CGFloat)from to:(CGFloat)to delay:(NSTimeInterval)delay  duration:(NSTimeInterval)durtion hidden:(BOOL)hidden {
   
    CABasicAnimation *rotateAnimation= [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    
    rotateAnimation.timingFunction =[CAMediaTimingFunction functionWithName:timing];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:from];
    rotateAnimation.toValue = [NSNumber numberWithFloat:to];
    rotateAnimation.duration = durtion;
    rotateAnimation.delegate = self;
    
    //不还原动画
    rotateAnimation.fillMode = kCAFillModeForwards;
    rotateAnimation.removedOnCompletion = NO;
    
    rotateAnimation.beginTime = CACurrentMediaTime() + delay;
    
    _hiddenAfterAnimation = hidden;
    
    [self.layer addAnimation:rotateAnimation forKey:@"rotation.x"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if (_hiddenAfterAnimation) {
        
        self.alpha = 0;
    }
    
    //    if(UIKeyboardDidHideNotification) self.alpha=0.8;
    
    [self.layer removeAllAnimations];
    self.layer.shouldRasterize = NO;
   
    //    [self rotatedX:0];
}


- (void)animationDidStart:(CAAnimation *)anim {
   
    self.layer.shouldRasterize = YES;
    self.alpha = 1;
}


@end

