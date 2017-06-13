//
//  ViewController.m
//  UpToCheckDetail
//
//  Created by 史振宇 on 2017/6/1.
//  Copyright © 2017年 SZY. All rights reserved.
//

#import "ViewController.h"
#import "ProductDetailViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
  
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.center = self.view.center;
    
    btn.bounds = CGRectMake(0, 0, 50, 50);
    
    btn.backgroundColor = [UIColor cyanColor];
    
    [btn  addTarget:self action:@selector(pushGoodDetailVC) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    
}

- (void)pushGoodDetailVC {
    
    ProductDetailViewController *productDetailVC = [[ProductDetailViewController alloc]init];
    
    productDetailVC.title = @"商品详情";
    
    [self.navigationController pushViewController:productDetailVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
