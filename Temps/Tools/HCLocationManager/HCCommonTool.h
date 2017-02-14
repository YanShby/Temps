//
//  HCCommonTool.h
//  LocationManagerDemo
//
//  Created by Jentle on 16/9/1.
//  Copyright © 2016年 Jentle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCCommonTool : NSObject

+ (void)addSecConfirmAlertWithController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message confiemAction:(void(^)(UIAlertAction *action))confiemAction;

@end
