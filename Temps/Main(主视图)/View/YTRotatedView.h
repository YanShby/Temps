//
//  RotatedView.h
//  YanTemps
//
//  Created by Yans on 2016/11/30.
//  Copyright © 2016年 Yans. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTRotatedView : UIView

@property(nonatomic,strong) YTRotatedView *backView;

@property(nonatomic,assign) BOOL hiddenAfterAnimation;

- (void)foldingAnimation:(NSString *)timing from:(CGFloat)from to:(CGFloat)to delay:(NSTimeInterval)delay duration:(NSTimeInterval)durtion hidden:(BOOL)hidden;
- (void)addBackViewHeight:(CGFloat)height color:(UIColor *)color;

@end
