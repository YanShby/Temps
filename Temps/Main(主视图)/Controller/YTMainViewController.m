//
//  ViewController.m
//  YanTemps
//
//  Created by Yans on 2016/11/30.
//  Copyright © 2016年 Yans. All rights reserved.
//

#import "YTMainViewController.h"
#import "YTAddLocationViewController.h"

#import "YTFoldTableViewCell.h"
#import "YTDataDownloader.h"
#import "YTWeatherData.h"
#import "YTBackView.h"
#import "YTLocation.h"

#import <SVProgressHUD.h>


@interface YTMainViewController() <UITableViewDelegate, UITableViewDataSource, YTAddLocationViewControllerDelegate>

//*********************************一大波属性******************************************//
/**添加地区控制器*/
@property (nonatomic, strong) YTAddLocationViewController *addLocationVC;
/**高度*/
@property (nonatomic, strong) NSMutableArray *heightArray;
/**主页面的tableView*/
@property (weak, nonatomic) IBOutlet UITableView *rotateTableView;
/**背景View*/
@property (nonatomic, strong) YTBackView *backView;
/**获取本地地点*/
@property (nonatomic, readwrite) CLLocationManager   *locationManager;
/**存放自定义YTLocation数据*/
@property (nonatomic, strong) NSMutableArray *locations;
/**内存中的YTWeatherData数据，根据缓存中的locations数组中的CLLocation来加载数据*/
@property (nonatomic, strong) NSMutableArray *weathers;
/**防止调用定位方法*/
@property (nonatomic, assign) BOOL isCall;
/**判断是否为更新数据。当界面已经有数据时，再次进入程序更新数据，值为YES；如果是首次运行程序，值为NO*/
@property (nonatomic, assign) BOOL isUpdate;
//*********************************一大波属性******************************************//

@end

@implementation YTMainViewController

#pragma mark - 懒加载
- (NSMutableArray *)heightArray {
    
    if (_heightArray == nil) {
        
        _heightArray = [NSMutableArray array];
        
        for (NSUInteger i = 0 ; i <= _weathers.count + 1; i++) {
            
            [_heightArray addObject:[NSNumber numberWithFloat:YTCloseCellHeight]];
        }
        
    }
    
    return _heightArray;
}

- (NSMutableArray *)weathers {
    
    if (_weathers == nil) {
        _weathers = [NSMutableArray array];
    }
    return _weathers;
}

- (NSMutableArray *)locations {
    
    if (_locations == nil || _locations.count == 0) {
        _locations = (NSMutableArray *)[YTSaveTool unarchiveObjectWithFile:YTSaveLocations];

        if (_locations == nil || _locations.count == 0) {
            _locations = [NSMutableArray array];
            [self initBackView];
        }
        
        YTWeatherData *data = [[YTWeatherData alloc] init];
        for (int i = 0; i < _locations.count; i++) {
            [self.weathers addObject:data];
        }
        
    }
    [self heightArray];
    
    return _locations;
}

#pragma mark - view的生命周期
- (void)viewDidLoad {
   
    [super viewDidLoad];

    [self initLocation];

    [self initRotateTableView];
    
    _addLocationVC = [[YTAddLocationViewController alloc] init];
    _addLocationVC.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    //判断是否为更新数据
    self.isUpdate = (self.locations.count == 0) ? NO : YES;
    //视图显示完毕开始定位
    [self.locationManager startUpdatingLocation];
    if (self.isUpdate)
        [self updateData];
}

#pragma mark - 初始化
//定位初始化
- (void)initLocation {
    
    self.locationManager                 = [[CLLocationManager alloc] init];
    self.locationManager.delegate        = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    self.isCall                          = NO;
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        //请求用户授权--> 当用户在使用的时候授权, 还需要增加info.plist的一个key
        [self.locationManager requestWhenInUseAuthorization];
    }

}

//初始化RotateTableView
- (void)initRotateTableView {
    
    self.rotateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.rotateTableView registerNib:[UINib nibWithNibName:NSStringFromClass([YTFoldTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"cell"];
    
}

//初始化BackView
- (void)initBackView {
    
    if (_locations.count == 0) {
        if (!_backView) {
            _backView = [YTBackView backView];
        }
        [self.view insertSubview:_backView atIndex:1];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - tableViewDataSource 和 tableViewDelegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return  [self locations].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [_heightArray[indexPath.row] floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    YTFoldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    YTWeatherData *data = [_weathers objectAtIndex:indexPath.row];
    
    cell.weatherData = data;

    if ([_heightArray[indexPath.row] floatValue] == YTCloseCellHeight) {
        
        [cell selectedAnimation:NO animated:NO completion:nil];
    }else {
        
        [cell selectedAnimation:YES animated:NO completion:nil];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YTFoldTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //cell正在动画中不能操作
    if([cell isAnimating]) return;
    
    CGFloat durtion = 0.0;
   
    if([_heightArray[indexPath.row] floatValue] == YTCloseCellHeight) {
       
        [_heightArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:YTOpenCellHeight]];
       
        durtion = 0.3;
       
        [cell selectedAnimation:YES animated:YES completion:nil];
        
    }else {
       
        durtion = [cell returnSumTime];
       
        [_heightArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:YTCloseCellHeight]];
       
        [cell selectedAnimation:NO animated:YES completion:nil];
    }
    
    [UIView animateWithDuration:durtion + 0.3 animations:^{
       
        [self.rotateTableView beginUpdates];
        [self.rotateTableView endUpdates];
    }];
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    return UITableViewCellEditingStyleDelete;
}

// 自定义左滑显示编辑按钮
-(NSArray<UITableViewRowAction*>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                         title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                                                                             
                                                                             //两个数组都要删除
                                                                             [_weathers removeObjectAtIndex:indexPath.row];
                                                                             [_locations removeObjectAtIndex:indexPath.row];
                           
                                                                             [YTSaveTool archiveRootObject:_locations toFile:YTSaveLocations];

                                                                             [UIView transitionWithView:self.rotateTableView
                                                                                               duration: 0.35f
                                                                                                options: UIViewAnimationOptionTransitionCrossDissolve
                                                                                             animations: ^(void)  
                                                                              {  
                                                                                  [self.rotateTableView reloadData];
                                                                              }  
                                                                                             completion: ^(BOOL isFinished)  
                                                                              {  
                                                                                  
                                                                              }];
                                                                            
                                                                         }];
    delete.backgroundColor = [UIColor clearColor];
    
    return @[delete];
}

#pragma mark - 获取数据
/**
 *  更新天气数据。
 *  根据weathers数组中的天气数据对象的属性local来获得CLLocation对象，然后根据这个location更新数据
 */
- (void)updateData {

    for (int i = 0 ; i < _locations.count; i++) {
        YTLocation *location = _locations[i];
        YTLog(@"here:location---%d",location.here);
        [self updateWeatherData:location atIndex:i];
    }
    
}

/**
 *  更新界面上对应位置的数据
 *
 *  @param location 地点对象
 *  @param index    weathers数组中对应的位置，每个位置都有一个天气数据对象
 */
- (void)updateWeatherData:(YTLocation *)location atIndex:(NSInteger)index {

    
    [[YTDataDownloader sharedDownloader] dataForLocation:location showStatus:@"正在更新数据" showDone:nil completion:^(YTWeatherData *data, NSError *error) {

        if (error && !data) {
            
            [self downloadFailed];
            
        } else {
            
            [self downloadSuccessForData:data atIndex:index];
            
        }
        
    }];

}

/**
 *  根据相应位置来获得新数据，替换原来的旧数据
 *
 *  @param data  更新之后的天气数据
 *  @param index 该地点在weathers数组中的位置
 */
- (void)downloadSuccessForData:(YTWeatherData *)data atIndex:(NSInteger)index {

    [_weathers replaceObjectAtIndex:index withObject:data];
    [self.rotateTableView reloadData];
    
}

/**
 *  获取数据失败
 */
- (void)downloadFailed {
    
    [SVProgressHUD showErrorWithStatus:@"更新数据失败"];
}

/**
 *  获取本地数据
 *
 *  @param location 定位的本地location
 */
- (void)acquireDataWithLocation:(YTLocation *)location {
    
    [[YTDataDownloader sharedDownloader] dataForLocation:location showStatus:@"正在获取数据" showDone:nil completion:^(YTWeatherData *data, NSError *error) {
        if (error && !data) {
            
            [self downloadFailed];
            
        } else {

            [self.weathers addObject:data];
            [_locations addObject:location];
            
            if (_backView != nil) {
                [_backView removeFromSuperview];
            }
            
            [self.rotateTableView reloadData];
            
            [YTSaveTool archiveRootObject:_locations toFile:YTSaveLocations];
        }
    }];
}


#pragma mark - <CLLocationManagerDelegate>
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    if (self.isCall) return;

    YTLocation *location = [YTLocation locationWithCLLocation:[locations lastObject]];
    location.here = YES;
    
    /**
     * 如果界面上没有数据（self.isUpdate == NO）那么直接下载定位数据
     * 如果界面上已经添加过数据，那么首先更改第一个位置上的定位数据，然后在更新数据。
     */
    if (self.isUpdate) {
        [_locations replaceObjectAtIndex:0 withObject:location];
    } else {
        [self acquireDataWithLocation:location];
    }

    self.isCall = YES;
    [self.locationManager stopUpdatingLocation];
    
}

#pragma mark - 按钮点击事件
//弹出增添地区天气的view
- (IBAction)tap:(id)sender {

    [self.view addSubview:_addLocationVC.view];
    
    CATransition *animation = [CATransition animation];
    animation.type = @"fade";
    animation.duration = 0.4;
    
    [self.view.layer addAnimation:animation forKey:nil];
}

#pragma mark - <YTAddLocationViewControllerDelegate>
-(void)addLocaionVC:(YTAddLocationViewController *)viewController didClickCellWithPlacemark:(CLPlacemark *)placemark {

    YTLocation *location = [YTLocation locationWithCLLocation:placemark.location];
    location.here = NO;
    if (placemark.subLocality) {
        location.cityName = placemark.subLocality;
    } else if (placemark.locality) {
        location.cityName = placemark.locality;
    }
    
    YTLog(@"CITYNAME ---- %@",location.cityName);
    
    [self acquireDataWithLocation:location];
    
    [_heightArray addObject:[NSNumber numberWithFloat:YTCloseCellHeight]];

}

@end
