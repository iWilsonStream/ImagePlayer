//
//  ImagePlayer.h
//  ImagePlayerDemo
//
//  Created by 蓝泰致铭 on 16/5/11.
//  Copyright © 2016年 netschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImagePlayerDelegate;

@interface ImagePlayer : UIView

/**
 *  ImagePlayerDelegate
 */
@property (nonatomic, assign) id <ImagePlayerDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame target:(UIViewController<ImagePlayerDelegate> *)target;

/**
 *  滚动的时间间隔
 */
@property (nonatomic, assign) NSUInteger interval;

/**
 *  是否显示pageControl，默认为YES
 */
@property (nonatomic, assign) BOOL showPageControl;

/**
 *  是否显示titleView，默认为YES
 */
@property (nonatomic, assign) BOOL showTitleLabl;


/**
 *  刷新整个ImagePlayer控件
 */
- (void)reload;

@end


@protocol ImagePlayerDelegate <NSObject>

@required

- (NSInteger)numberOfItems;

/**
 *  @param 当前页的视图控制器
 *  @param 当前页的位置
 */
- (void)loadImageView:(UIImageView *)imageView atIndex:(NSInteger)index;

@optional

/**
 *  @param 当前页的位置
 * 
 *  return 当前页的标题
 */
- (void)titleForLabel:(UILabel *)titlelab currentPage:(NSInteger)index;

/**
 *  @param 视图播放器对象
 *
 *  @param 当前点击视图的位置
 */
- (void)imagePlayer:(ImagePlayer *)player didSelectedAtIndex:(NSInteger)index;


@end