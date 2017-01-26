//
//  ViewController.h
//  YanTemps
//
//  Created by Yans on 2016/11/30.
//  Copyright © 2016年 Yans. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTMainViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, readonly) CLLocationManager   *locationManager;

- (void)updateData;

@end

