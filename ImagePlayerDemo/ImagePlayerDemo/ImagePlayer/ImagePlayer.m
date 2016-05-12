//
//  ImagePlayer.m
//  ImagePlayerDemo
//
//  Created by 蓝泰致铭 on 16/5/11.
//  Copyright © 2016年 netschina. All rights reserved.
//

#import "ImagePlayer.h"
#import "Masonry.h"

#define RunLoopManager         [[NSRunLoop currentRunLoop] run];
#define TimerManager(interval) [self setupTimer:interval];
#define GetNumberOfItems       [self.delegate numberOfItems];
#define kScreen_Size           [UIScreen mainScreen].bounds.size

#define ImagePlayerSize CGSizeMake(kScreen_Size.width, kScreen_Size.width * 9 / 16)
#define DefaultInterval 3.0f
#define DelayInterval   2.0f

@interface ImagePlayer ()<UIScrollViewDelegate>

/**
 *  定时器，用来做定时跳转
 */
@property (nonatomic, strong) NSTimer * timer;

/**
 *  分页器，用来显示当前页及点击对应页跳转
 */
@property (nonatomic, strong) UIPageControl * pageControl;

/**
 *  滚动视图，用来承载所需要滚动的对象
 */
@property (nonatomic, strong) UIScrollView * containerScrollView;

/**
 *  标题背景view
 */
@property (nonatomic, strong) UIView * titlebackView;

/**
 *  标题label
 */
@property (nonatomic, strong) UILabel * titleLabl;

/**
 *  需要滚动的对象个数
 */
@property (nonatomic, assign) NSInteger count;

@end

@implementation ImagePlayer

#pragma mark - init functions
- (instancetype)initWithFrame:(CGRect)frame target:(UIViewController<ImagePlayerDelegate> *)target{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.delegate = target;
        [self layoutAllSubviews];
    }
    return self;
}

- (void)layoutAllSubviews {
    __weak typeof(self) weakSelf = self;
    
    //1.初始化container
    _containerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ImagePlayerSize.width, ImagePlayerSize.height)];
    _containerScrollView.pagingEnabled = YES;
    _containerScrollView.bounces = NO;
    _containerScrollView.userInteractionEnabled = YES;
    _containerScrollView.backgroundColor = [UIColor clearColor];
    _containerScrollView.showsVerticalScrollIndicator = NO;
    _containerScrollView.showsHorizontalScrollIndicator = NO;
    _containerScrollView.directionalLockEnabled = YES;
    _containerScrollView.delegate = self;
    [self addSubview:_containerScrollView];
    
    //2.初始化titleBackview
    UIView * titleBackView = [UIView new];
    titleBackView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"homepage_black_half_bg.png"]];
    [self addSubview:titleBackView];
    [titleBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.containerScrollView.mas_left);
        make.top.mas_equalTo(weakSelf.containerScrollView.mas_bottom).offset(-40);
        make.size.mas_equalTo(CGSizeMake(ImagePlayerSize.width, 40));
    }];
    self.titlebackView = titleBackView;
    
    //3.初始化pageControl
    UIPageControl * pageControl = [UIPageControl new];
    [self.titlebackView addSubview:pageControl];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:203/255.0f green:30/255.0f blue:5/255.0f alpha:1];
    pageControl.userInteractionEnabled = YES;
    pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    pageControl.hidden = NO;
    pageControl.currentPage = 0;
    [pageControl addTarget:self action:@selector(handleTapActionOfPageControl:) forControlEvents:UIControlEventTouchUpInside];
    [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(titleBackView);
        make.top.mas_equalTo(titleBackView.mas_top);
        make.height.mas_equalTo(30);
    }];
    self.pageControl = pageControl;
    
    //4.初始化titleView
    UILabel * titleLabl = [UILabel new];
    [self.titlebackView addSubview:titleLabl];
    titleLabl.backgroundColor = [UIColor clearColor];
    titleLabl.textColor       = [UIColor whiteColor];
    titleLabl.textAlignment   = NSTextAlignmentCenter;
    titleLabl.font            = [UIFont fontWithName:@"Arial" size:11];
    titleLabl.hidden          = NO;
    [titleLabl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleBackView.mas_left);
        make.top.mas_equalTo(pageControl.mas_bottom).offset(-5);
        make.size.mas_equalTo(CGSizeMake(ImagePlayerSize.width, 10));
    }];
    self.titleLabl = titleLabl;
    
    //5.初始化timer，默认不走针
    TimerManager(self.interval)
    [self performSelector:@selector(setupPlayer) withObject:nil afterDelay:0];
}

#pragma mark - setter
- (void)setInterval:(NSUInteger)interval {
    _interval = interval;
    TimerManager(self.interval)
}

- (void)setupTimer:(CGFloat)interval {
    interval = interval == 0 ? DefaultInterval : interval;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(playerDidRolling) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)setupPlayer {
    self.count = GetNumberOfItems
    //1.过滤异常值 必须遵循delegate代理
    if(self.count <= 0 || !self.delegate) {
        self.containerScrollView.hidden = YES;
        self.titlebackView.hidden       = YES;
        [_timer setFireDate:[NSDate distantFuture]];
        return;
    }
    
    //2.给pageControl赋值
    self.pageControl.numberOfPages = self.count;
    
    //3.给containerScrollView内容
    for(NSUInteger i = 0; i < self.count; i ++) {
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * ImagePlayerSize.width, 0, ImagePlayerSize.width, ImagePlayerSize.height)];
        
        imageView.userInteractionEnabled = YES;
        [imageView setTag:i];
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapActionForImage:)]];
        [self.containerScrollView addSubview:imageView];
        
        //用于设置imageView的显示image
        if(self.delegate && [self.delegate respondsToSelector:@selector(loadImageView:atIndex:)]) {
            [self.delegate loadImageView:imageView atIndex:i];
        }
    }
    
    self.containerScrollView.contentSize = CGSizeMake(ImagePlayerSize.width * self.count, ImagePlayerSize.height);
    self.containerScrollView.contentInset = UIEdgeInsetsZero;
    
    //4.在没有开始滚动之前，默认显示第一页的title
    if(self.delegate && [self.delegate respondsToSelector:@selector(titleForLabel:currentPage:)]) {
        [self.delegate titleForLabel:self.titleLabl currentPage:0];
    }
    
    //5.开始滚动
    [self performSelector:@selector(fireThePlayer) withObject:nil afterDelay:DelayInterval];
}

#pragma mark - userInteract actions
- (void)handleTapActionOfPageControl:(UIPageControl *)pageControl {
    
    CGPoint contentOffset = CGPointZero;
    contentOffset.x = pageControl.currentPage * ImagePlayerSize.width;
    
    if(pageControl.currentPage == self.count) {
        self.containerScrollView.contentOffset = contentOffset;
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.containerScrollView.contentOffset = contentOffset;
        }];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(titleForLabel:currentPage:)]) {
        [self.delegate titleForLabel:self.titleLabl currentPage:pageControl.currentPage];
    }
    
    //重新生成计时器
    TimerManager(self.interval)
}

- (void)handleTapActionForImage:(UITapGestureRecognizer *)tap {
    if(self.delegate && [self.delegate respondsToSelector:@selector(imagePlayer:didSelectedAtIndex:)]) {
        [self.delegate imagePlayer:self didSelectedAtIndex:tap.view.tag];
    }
}

#pragma mark - timer action
//开始计时滚动处理
- (void)playerDidRolling {
    //1.过滤异常值
    if(self.count <= 0) return;
    
    //2.防止数组越界
    NSInteger currentPage = self.pageControl.currentPage;
    NSInteger nextPage    = currentPage + 1;
    if(nextPage == self.count) {
        nextPage = 0;
    }
    
    //3.设置scrollView自动偏移
    CGPoint contentOffset = CGPointZero;
    contentOffset.x       = nextPage * ImagePlayerSize.width;
    if(nextPage == 0) {//第0页不用动画滚动
        self.containerScrollView.contentOffset = contentOffset;
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.containerScrollView.contentOffset = contentOffset;
        }];
    }
    
    //4.设置scrollView停止滚动后当前页的标题
    if(self.delegate && [self.delegate respondsToSelector:@selector(titleForLabel:currentPage:)]) {
        [self.delegate titleForLabel:self.titleLabl currentPage:nextPage];
        
        //5.每次调用此方法时，currentPage++
        self.pageControl.currentPage = nextPage;
    }
}

//开始滚动计时
- (void)fireThePlayer {
    //开火
    [_timer setFireDate:[NSDate distantPast]];
    //如果不加入runloop，则在拖动视图时会阻塞UI，导致拖动时无法滚动
    RunLoopManager
}

#pragma mark - imagePlayer delegate
- (void)reload {
    [self reloadData];
}

- (void)reloadData {
    //1.判断是否是有效的reload，如果空reload，直接return
    NSUInteger count = GetNumberOfItems
    if(count == 0) return;
    //2.remove掉scrollView上所有的imageView
    for(UIView * subview in self.containerScrollView.subviews) {
        [subview removeFromSuperview];
    }
    //3.将ImagePlayer中的scrollview的offset置0
    CGPoint contentOffset = self.containerScrollView.contentOffset;
    contentOffset.x = 0;
    self.containerScrollView.contentOffset = contentOffset;
    //4.将当前页书置0
    self.pageControl.currentPage   = 0;
    //5.重设player
    [self performSelector:@selector(setupPlayer) withObject:nil afterDelay:0];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    NSInteger currentPage = contentOffset.x / ImagePlayerSize.width;
    self.pageControl.currentPage = currentPage;
    if(self.delegate && [self.delegate respondsToSelector:@selector(titleForLabel:currentPage:)]) {
        [self.delegate titleForLabel:self.titleLabl currentPage:currentPage];
    }
    //重新计时
    TimerManager(self.interval)
}

@end
