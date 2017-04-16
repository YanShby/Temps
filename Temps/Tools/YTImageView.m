//
//  YTImageView.m
//  Temps
//
//  Created by Yans on 2017/4/16.
//  Copyright © 2017年 Ewane Shen. All rights reserved.
//

#import "YTImageView.h"

@interface YTImageView ()

@property (nonatomic, strong) UIVisualEffectView *blurView;

@end


@implementation YTImageView

- (void)setYt_Image:(UIImage *)yt_Image
{
    if(_yt_Image != yt_Image)
    {
        _yt_Image = yt_Image;
        [self setNeedsDisplay];
    }
}

- (UIVisualEffectView *)blurView
{
    if (_blurView == nil)
    {
        _blurView = [[UIVisualEffectView alloc] init];
        _blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        [self addSubview:_blurView];
    }
    
    return _blurView;
}

- (void)drawRect:(CGRect)rect
{
    [self.yt_Image drawInRect:rect];
//    self.blurView.frame = rect;
}


@end
