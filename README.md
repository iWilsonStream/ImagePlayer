# ImagePlayer
这是一个图片播放器，支持自动滚动，手动滚动，点击PageControl滚动等事件；加入了防UI阻塞机制，在tableview拖动时不会致使Player停止滚动；介入只需几行代码，使用便利


# 接入

1. import "ImagePlayer.h"

2. 务必先遵循代理 ImagePlayerDelegate

3. 初始化player

//初始化
- (void)layoutPlayer {
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9 / 16);
    ImagePlayer * player = [[ImagePlayer alloc] initWithFrame:rect target:self];
    //不给定时间间隔的话，默认每隔3秒滚动1次
    player.interval = 3.f;
    [self.view addSubview:player];
    self.player = player;
}

注意，这里ImagePlayer的尺寸比例是16:9

4. 实现代理方法

@required

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

@optional

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