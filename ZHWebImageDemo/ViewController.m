//
//  ViewController.m
//  ZHWebImage
//
//  Created by Babr2 on 17/4/4.
//  Copyright © 2017年 Babr2. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+Cache.h"

#define kTestURL @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1491328602548&di=f1e613599e63d0222fe46ac94dcc910a&imgtype=0&src=http%3A%2F%2Fimg2.niutuku.com%2Fdesk%2F261%2F261-27041.jpg"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIImageView *view=[[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 200, 150)];
    [self.view addSubview:view];
    view.backgroundColor=[UIColor grayColor];
    [view zh_setImageWihtUrlString:kTestURL placeHolder:[UIImage imageNamed:@"placeHolder"]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
