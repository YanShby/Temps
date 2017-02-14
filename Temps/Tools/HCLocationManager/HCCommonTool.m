//
//  HCCommonTool.m
//  LocationManagerDemo
//
//  Created by Jentle on 16/9/1.
//  Copyright © 2016年 Jentle. All rights reserved.
//

#import "HCCommonTool.h"

@implementation HCCommonTool

/**
 *  二次确认弹框
 */
+ (void)addSecConfirmAlertWithController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message confiemAction:(void(^)(UIAlertAction *action))confiemAction{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (confiemAction) {
            confiemAction(action);
        }
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancleAction];
    [alert addAction:okAction];
    [viewController presentViewController:alert animated:true completion:nil];
}


@end
