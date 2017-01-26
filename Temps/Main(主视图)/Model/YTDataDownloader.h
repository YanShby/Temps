//
//  YTDataDownloader.h
//  YanTemps
//
//  Created by Yans on 2017/1/2.
//  Copyright © 2017年 Yans. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YTWeatherData;

typedef void (^YTWeatherDataDownloadCompletion)(YTWeatherData *data, NSError *error);

@interface YTDataDownloader : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>


+ (YTDataDownloader *)sharedDownloader;

- (void)dataForLocation:(CLLocation *)location completion:(YTWeatherDataDownloadCompletion)completion;

@end
