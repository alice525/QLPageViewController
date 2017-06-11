//
//  ViewController.m
//  QLPageViewController
//
//  Created by alicejhchen on 17/5/30.
//  Copyright © 2017年 tencentVideo. All rights reserved.
//

#import "ViewController.h"
#import "QNBPageViewController.h"
#import "QLTabViewController.h"

@interface ViewController () <QNBPageViewControllerDataSource,QNBPageViewControllerDelegate>

@property (nonatomic, strong) UIView *topTabView;
@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;
@property (nonatomic, strong) UIButton *button3;

@property (nonatomic, strong) QNBPageViewController *pageViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat buttonH = 40;
    
    _topTabView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, screenWidth, buttonH)];
    [self.view addSubview:_topTabView];
    
    _button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenWidth/3, buttonH)];
    [_button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _button1.backgroundColor = [UIColor whiteColor];
    [_button1 setTitle:@"tap1" forState:UIControlStateNormal];
    [_button1 addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    
    _button2 = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/3, 0, screenWidth/3, buttonH)];
    [_button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _button2.backgroundColor = [UIColor whiteColor];
    [_button2 setTitle:@"tap2" forState:UIControlStateNormal];
    [_button2 addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    
    _button3 = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth/3 * 2, 0, screenWidth/3, buttonH)];
    [_button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _button3.backgroundColor = [UIColor whiteColor];
    [_button3 setTitle:@"tap3" forState:UIControlStateNormal];
    [_button3 addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_topTabView addSubview:_button1];
    [_topTabView addSubview:_button2];
    [_topTabView addSubview:_button3];
    
    _pageViewController = [[QNBPageViewController alloc] initWithNibName:nil bundle:nil];
    
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    
    [self addChildViewController:_pageViewController];
    _pageViewController.view.frame = CGRectMake(0, CGRectGetMaxY(_topTabView.frame), screenWidth, CGRectGetHeight(self.view.frame)-CGRectGetMaxY(_topTabView.frame));
    _pageViewController.view.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didTapButton:(id)sender {
    if (sender == _button1) {
        [_pageViewController showPageAtIndex:0 animated:YES];
    } else if (sender == _button2) {
        [_pageViewController showPageAtIndex:1 animated:YES];
    } else {
        [_pageViewController showPageAtIndex:2 animated:YES];
    }
}

#pragma mark QLPageViewControllerDataSource
// 对应index的controller
- (UIViewController *)pageViewController:(QNBPageViewController *)pageViewController controllerAtIndex:(NSUInteger)index {
    QLTabViewController *VC = [[QLTabViewController alloc] initWithNibName:nil bundle:nil];
    VC.index = index;
    
    if (index == 0) {
        VC.view.backgroundColor = [UIColor blueColor];
    } else if (index == 1) {
        VC.view.backgroundColor = [UIColor purpleColor];
    } else {
        VC.view.backgroundColor = [UIColor greenColor];
    }
    
    return VC;
}

// child controller的个数
- (NSInteger)numberOfControllersInPageViewController:(QNBPageViewController *)pageViewController {
    return 3;
}

// 页面宽度
- (CGSize)sizeOfOnePageInPageViewController:(QNBPageViewController *)pageViewController {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, CGRectGetHeight(self.view.frame)-CGRectGetMaxY(_topTabView.frame));
}

@end
