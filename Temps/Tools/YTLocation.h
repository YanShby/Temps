//
//  YTLocation.h
//  Temps
//
//  Created by Yans on 2017/2/9.
//  Copyright © 2017年 Ewane Shen. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface YTLocation : CLLocation <NSCoding>
/**是否是本地*/
@property (nonatomic, assign, getter=isHere) BOOL here;
@end
