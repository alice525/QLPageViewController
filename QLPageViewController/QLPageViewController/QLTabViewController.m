//
//  QLTabViewController.m
//  QLPageViewController
//
//  Created by alicejhchen on 2017/6/6.
//  Copyright © 2017年 tencentVideo. All rights reserved.
//

#import "QLTabViewController.h"

@interface QLTabViewController ()

@property (nonatomic, strong) UILabel *indexLbl;

@end

@implementation QLTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _indexLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    _indexLbl.text = @(_index).stringValue;
    _indexLbl.textColor = [UIColor whiteColor];
    
    NSLog(@"%zd viewDidLoad", _index);
}

- (void)viewWillLayoutSubviews {
    _indexLbl.frame = CGRectMake(100, 100, 50, 50);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"%zd viewWillAppear", _index);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"%zd viewDidAppear", _index);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"%zd viewWillDisappear", _index);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSLog(@"%zd viewDidDisappear", _index);
}

@end
