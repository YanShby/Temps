//
//  YTForecastTableViewCell.m
//  YanTemps
//
//  Created by Yans on 2016/11/30.
//  Copyright © 2016年 Yans. All rights reserved.
//

#import "YTForecastTableViewCell.h"
#import "YTForecastData.h"

@interface YTForecastTableViewCell ()
//星期
@property (weak, nonatomic) IBOutlet UILabel *dayOfWeek;
//天气状况
@property (weak, nonatomic) IBOutlet UIImageView *weatherIcon;
//最低  （H 20° L 10°）
@property (weak, nonatomic) IBOutlet UILabel *low;
//最高
@property (weak, nonatomic) IBOutlet UILabel *high;

@end

@implementation YTForecastTableViewCell

- (void)awakeFromNib {

    [super awakeFromNib];
    
    self.selectionStyle   = UITableViewCellSelectionStyleNone;

}

- (void)setForecastData:(YTForecastData *)forecastData {

    self.dayOfWeek.text   = forecastData.dayOfWeek;
    self.weatherIcon.image = forecastData.weatherIcon;
    self.high.text        = [NSString stringWithFormat:@"%@°",forecastData.high];
    self.low.text         = [NSString stringWithFormat:@"%@°",forecastData.low];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
}

@end
