//
//  ViewController.m
//  HostResolutionDemo
//
//  Created by ChenHao on 15/3/26.
//  Copyright (c) 2015年 ChenHao. All rights reserved.
//

#import "ViewController.h"

#import "SKHost.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *hostBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 200, CGRectGetWidth(self.view.bounds), 44)];
    [hostBtn setTitle:@"Host resolve" forState:UIControlStateNormal];
    [hostBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [hostBtn addTarget:self action:@selector(hostResolve:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hostBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hostResolve:(UIButton *)sender
{
    [SKHost getHostAddressByName:@"www.baidu.com" completion:^(BOOL completion, NSArray *result) {
        NSLog(@"completion: %@", result);
    }];
}

@end
