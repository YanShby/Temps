//
//  YTBackView.m
//  YanTemps
//
//  Created by Yans on 2017/1/4.
//  Copyright © 2017年 Yans. All rights reserved.
//

#import "YTBackView.h"

@implementation YTBackView

+ (instancetype)backView {

    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil][0];
}

- (void)awakeFromNib {

    [super awakeFromNib];

    [self setUp];
}

- (void)setUp {

    self.backgroundColor = [UIColor clearColor];

    self.frame           = CGRectMake(0, 0, YTScreenW * 0.7, YTScreenW * 0.7);

    CGPoint centerP      = CGPointMake(YTScreenW * 0.5, YTScreenH * 0.5);

    self.center          = centerP;

}

@end
