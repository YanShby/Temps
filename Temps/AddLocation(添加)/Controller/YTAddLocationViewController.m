//
//  YTAddLocationViewController.m
//  YanTemps
//
//  Created by Yans on 2017/1/4.
//  Copyright © 2017年 Yans. All rights reserved.
//

#import "YTAddLocationViewController.h"
#import "DRNRealTimeBlurView.h"

static NSString *ID = @"cell";

@interface YTAddLocationViewController () <UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

/**topView*/
@property (nonatomic, strong) UIView *topBar;
/**搜索条*/
@property (nonatomic, strong) UISearchBar *searchBar;
/**结果tableView*/
@property (nonatomic, strong) UITableView *resultView;
/**地理编码对象*/
@property (nonatomic, strong) CLGeocoder *geocoder;
/**存放解码的CLPlacemark数组*/
@property (nonatomic, strong) NSMutableArray *placemarks;



@end

@implementation YTAddLocationViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view = [[DRNRealTimeBlurView alloc] init];
    
    self.view.frame = CGRectMake(0, 0, YTScreenW, YTScreenH);


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setTopBar];
    [self setSearchBar];
    [self setTableView];
}

- (void)setTopBar {
    
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YTScreenW, 70)];
    topBar.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
    _topBar = topBar;
    [self.view addSubview:topBar];

    
}

- (void)setSearchBar {
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.frame = CGRectMake(0, 30, YTScreenW, 44);
    searchBar.barStyle = UIBarStyleBlack;
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.placeholder = @"输入城市";
    searchBar.showsCancelButton = YES;
    searchBar.tintColor = [UIColor whiteColor];
    searchBar.delegate = self;
    
    UITextField *searchField = [searchBar valueForKey:@"_searchField"];
    UILabel *placeholderLable = [searchField valueForKey:@"_placeholderLabel"];
    placeholderLable.textColor = [UIColor whiteColor];
    searchField.textColor= [UIColor whiteColor];
    
    [searchBar becomeFirstResponder];
    _searchBar = searchBar;
    
    [_topBar addSubview:searchBar];
    
}

- (void)setTableView {
    
    _resultView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topBar.frame.size.height, YTScreenW, YTScreenH - _topBar.frame.size.height) style:UITableViewStylePlain];
    _resultView.delegate = self;
    _resultView.dataSource = self;
    _resultView.backgroundColor = [UIColor clearColor];
    _resultView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_resultView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];
    
    [self.view addSubview:_resultView];
    
}

- (CLGeocoder *)geocoder {
    
    if (_geocoder == nil) {
        
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (NSMutableArray *)placemarks {
    
    if (_placemarks == nil) {
        
        _placemarks = [NSMutableArray array];
    }
    return _placemarks;
}


#pragma mark - <UISearchBarDelegate>
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.6 animations:^{
        self.view.alpha = 0;

    } completion:^(BOOL finished) {
        self.placemarks = nil;
        [self.resultView reloadData];
        [self.view removeFromSuperview];
        self.view = nil;
        
    }];
    
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    YTLog(@"%@",searchText);
    self.placemarks = nil;
    [self.geocoder geocodeAddressString:searchText completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error == nil) {

            for (CLPlacemark *placemark in placemarks) {

                if ([placemark.locality containsString:searchText]) {
                    YTLog(@"%@",placemarks);
                    [self.placemarks addObject:placemark];
                }
            }

        }
        [self.resultView reloadData];
    }];
  
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = NO;
}

#pragma mark - <UITableViewDelegate UITbaleViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.placemarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    CLPlacemark *placemark = self.placemarks[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@",placemark.administrativeArea,placemark.locality];
    cell.backgroundColor = [UIColor clearColor];
    cell.textColor = [UIColor darkGrayColor];


    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    CLPlacemark *placemark = self.placemarks[indexPath.row];
    
    if ([_delegate respondsToSelector:@selector(addLocaionVC:didClickCellWithPlacemark:)]) {
        [_delegate addLocaionVC:self didClickCellWithPlacemark:placemark];
    }
    
    
    [self searchBarCancelButtonClicked:self.searchBar];
}


@end
