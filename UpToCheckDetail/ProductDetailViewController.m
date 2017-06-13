//
//  ProductDetailViewController.m
//  UpToCheckDetail
//
//  Created by 史振宇 on 2017/6/2.
//  Copyright © 2017年 SZY. All rights reserved.
//

#import "ProductDetailViewController.h"

#define ScreenWidth    [UIScreen mainScreen].bounds.size.width
#define ScreenHeight   [UIScreen mainScreen].bounds.size.height

#define maxContentOffset_Y  40

@interface ProductDetailViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>

@property (nonatomic,strong) UIScrollView *contentView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIWebView *webView;

@property (nonatomic,strong) UILabel *headTipLabel;

@end

@implementation ProductDetailViewController

#pragma mark -- Life Cycle
- (void)dealloc {
    
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentOffset" context:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
      [self loadContentView];
    
}

- (void)loadContentView {
    
    [self.contentView addSubview:self.tableView];
    
    [self.contentView addSubview:self.webView];
    
    // 监听webView.scrollView的偏移量
    [self.webView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self.webView addSubview:self.headTipLabel];
    
    [self.headTipLabel bringSubviewToFront:self.contentView];
}

#pragma mark -- ScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if ([scrollView isKindOfClass:[UITableView class]]) { //tableView界面上的滑动
        
        // 能触发翻页的理想值：tableView整体的高度减去屏幕本身的高度
        CGFloat valueNum = _tableView.contentSize.height - ScreenHeight; //tableView滑动到底部所需要的距离
        
        if ((offsetY - valueNum)>maxContentOffset_Y) {
            
            [self goToDetailAnimation]; //进入图文详情的动画
        }
        
    }
    
    else { //webView页面上的滑动
        
        if (offsetY < 0 && -offsetY > maxContentOffset_Y) {
            
            [self backToFirstPageAnimation]; //返回基本详情界面的动画
        }
        
    }
}

#pragma mark --进入详情的动画
- (void)goToDetailAnimation {
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        _webView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64);
        
        _tableView.frame = CGRectMake(0, -self.contentView.bounds.size.height, ScreenWidth, self.contentView.bounds.size.height - 64);
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark --返回第一个界面的动画
- (void)backToFirstPageAnimation {
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        _tableView.frame = CGRectMake(0, 0, ScreenWidth, self.contentView.bounds.size.height - 64);
        
        _webView.frame = CGRectMake(0, -_tableView.bounds.size.height, ScreenWidth, ScreenHeight - 64);
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark --KVO的代理方法，根据偏移量完成提示文本的动画
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (object == _webView.scrollView && [keyPath isEqualToString:@"contentOffset"]) {
        
        [self headTipLabelAnimation:[change[@"new"] CGPointValue].y];
        
    }else {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}


#pragma mark --提示文本的动画的实现代码
- (void)headTipLabelAnimation:(CGFloat)offsetY {
    
    _headTipLabel.alpha = -offsetY / 60;
    
    _headTipLabel.center = CGPointMake(ScreenWidth / 2, -offsetY/ 2.f);
    
    //图标翻转，表示已超过临界值，松手就会返回上页
    if (offsetY > maxContentOffset_Y) {
        
        _headTipLabel.textColor = [UIColor redColor];
        
        _headTipLabel.text = @"释放，返回详情";
    }else {
        
        _headTipLabel.textColor = [UIColor grayColor];
        _headTipLabel.text = @"上拉，返回详情";
    }
}

#pragma mark -- tableViewDelegate && tableDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"cell-%ld",(long)indexPath.row];
    
    return cell;
}


#pragma mark -- Setter && Getter
- (UIScrollView *)contentView {
    
    if (!_contentView) {
        
        _contentView = [[UIScrollView alloc]init];
        
        _contentView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        
        _contentView.delegate = self;
        
        [self.view addSubview:self.contentView];
        
    }
    
    return _contentView;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        
        _tableView.dataSource = self;
        
        _tableView.rowHeight = 50.f;
        
        UILabel *tableFooterLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
        tableFooterLabel.text = @"继续拖动，查看商品图文详情";
        tableFooterLabel.font = [UIFont systemFontOfSize:13];
        tableFooterLabel.textAlignment = NSTextAlignmentCenter;
        
        _tableView.tableFooterView = tableFooterLabel;
        
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        
    }
    
    return _tableView;
}

- (UIWebView *)webView {
    
    if (!_webView) {
        
        
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - 64)];
        
        _webView.delegate = self;
        
        _webView.scrollView.delegate = self;
        
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
        
    }
    
    return _webView;
}
- (UILabel *)headTipLabel {
    
    if (!_headTipLabel) {
        
        _headTipLabel = [[UILabel alloc]init];
        
        _headTipLabel.text = @"上拉，返回商品详情";
        
        _headTipLabel.textColor = [UIColor grayColor];
        
        _headTipLabel.font = [UIFont systemFontOfSize:13];
        
        _headTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    _headTipLabel.frame = CGRectMake(0, 0, ScreenWidth, 40.f);
    
    _headTipLabel.alpha = 0.f;
    
    return _headTipLabel;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
