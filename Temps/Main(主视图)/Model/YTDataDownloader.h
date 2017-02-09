//
//  YTDataDownloader.h
//  YanTemps
//
//  Created by Yans on 2017/1/2.
//  Copyright © 2017年 Yans. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YTWeatherData;
@class YTLocation;

typedef void (^YTWeatherDataDownloadCompletion)(YTWeatherData *data, NSError *error);

@interface YTDataDownloader : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>


+ (YTDataDownloader *)sharedDownloader;

- (void)dataForLocation:(YTLocation *)location showStatus:(NSString *)showStatus showDone:(NSString *)showDone completion:(YTWeatherDataDownloadCompletion)completion;

@end
