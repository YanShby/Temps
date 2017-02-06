//
//  YTAddLocationViewController.h
//  YanTemps
//
//  Created by Yans on 2017/1/4.
//  Copyright © 2017年 Yans. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YTAddLocationViewController;

@protocol YTAddLocationViewControllerDelegate <NSObject>

@optional
/**
 *  点击cell把placemark给传出去
 *
 *  @param viewController YTAddLocationViewController
 *  @param placemark      添加地点的placemark
 */
- (void)addLocaionVC:(YTAddLocationViewController *)viewController didClickCellWithPlacemark:(CLPlacemark *)placemark;

@end

@interface YTAddLocationViewController : UIViewController

@property (nonatomic, weak) id <YTAddLocationViewControllerDelegate> delegate;

@end
