//
//  ViewController.m
//  ImagePlayerDemo
//
//  Created by 蓝泰致铭 on 16/5/11.
//  Copyright © 2016年 netschina. All rights reserved.
//

#import "ViewController.h"
#import "ImagePlayer.h"
#import "BannerInfoModel.h"
#import "Masonry.h"

@interface ViewController ()<ImagePlayerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) ImagePlayer * player;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * array;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Image Player";
    [self testData];
    [self layoutPlayer];
    [self layoutTableView];
//    [self performSelector:@selector(reloadImagePlayer) withObject:nil afterDelay:10.f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

//- (void)reloadImagePlayer {
//    [self.array removeAllObjects];
//    
//    NSString * path = [[NSBundle mainBundle] pathForResource:@"source_data_2" ofType:@"plist"];
//    NSArray * array = [[NSArray alloc] initWithContentsOfFile:path];
//    
//    for(NSDictionary * dic in array) {
//        BannerInfoModel * model = [BannerInfoModel new];
//        [model setValuesForKeysWithDictionary:dic];
//        [self.array addObject:model];
//    }
//    
//    [self.player reload];
//}

//第一次无需reload
- (void)testData {
    NSString * path = [[NSBundle mainBundle] pathForResource:@"source_data" ofType:@"plist"];
    NSArray * array = [[NSArray alloc] initWithContentsOfFile:path];
    
    for(NSDictionary * dic in array) {
        BannerInfoModel * model = [BannerInfoModel new];
        [model setValuesForKeysWithDictionary:dic];
        [self.array addObject:model];
    }
}

//初始化
- (void)layoutPlayer {
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9 / 16);
    ImagePlayer * player = [[ImagePlayer alloc] initWithFrame:rect target:self];
    //不给定时间间隔的话，默认每隔3秒滚动1次
//    player.interval = 3.f;
    [self.view addSubview:player];
    self.player = player;
}

//在这里返回要加载的items个数,务必实现这个方法，并且确保array有值
- (NSInteger)numberOfItems {
    NSLog(@"进来了");
    return self.array.count;
}

//在这里加载每一页的图片
- (void)loadImageView:(UIImageView *)imageView atIndex:(NSInteger)index {
    BannerInfoModel * model = [self.array objectAtIndex:index];
    imageView.image = [UIImage imageNamed:model.imagePath];
}

//在这里加载每一页的标题
- (void)titleForLabel:(UILabel *)titlelab currentPage:(NSInteger)index {
    BannerInfoModel * model = [self.array objectAtIndex:index];
    titlelab.text = model.bannerTitle;
}

//在这里处理图片内容点击事件
- (void)imagePlayer:(ImagePlayer *)player didSelectedAtIndex:(NSInteger)index {
    BannerInfoModel * model = [self.array objectAtIndex:index];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.url]];
}

#pragma mark - tableView
- (void)layoutTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundView = nil;
    _tableView.rowHeight =  50;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top);
        make.left.mas_equalTo(self.view.mas_left);
        make.size.mas_equalTo(CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - 20));
    }];
    _tableView.tableHeaderView = self.player;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellID = @"cell";
    UITableViewCell * cell   = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld个cell",indexPath.row];
    
    return cell;
}

- (NSMutableArray *)array {
    if(!_array) {
        _array = [NSMutableArray array];
    }
    return _array;
}

- (NSMutableArray *)dataSource {
    if(!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
