//
//  QLPageViewController.h
//  QLPageViewController
//
//  Created by alicejhchen on 17/5/30.
//  Copyright © 2017年 tencentVideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QNBPageViewController;

@protocol QNBPageViewControllerDataSource <NSObject>

@required

// 对应index的controller
- (UIViewController *)pageViewController:(QNBPageViewController *)pageViewController controllerAtIndex:(NSUInteger)index;

// child controller的个数
- (NSInteger)numberOfControllersInPageViewController:(QNBPageViewController *)pageViewController;

// 页面size
- (CGSize)sizeOfOnePageInPageViewController:(QNBPageViewController *)pageViewController;

@end

@protocol QNBPageViewControllerDelegate <NSObject>

@optional

// 开始滑动scrollView时调用，通知外部即将从fromIndex页面滑动到toIndex页面
- (void)pageViewController:(QNBPageViewController *)pageViewController
                 willTransitionFromIndex:(NSUInteger)fromIndex
                                 toIndex:(NSUInteger)toIndex;

// scrollView滑动停止时调用，通知外部已经从fromIndex页面滑动到toIndex页面
- (void)pageViewController:(QNBPageViewController *)pageViewController
                  DidTransitionFromIndex:(NSUInteger)fromIndex
                                 toIndex:(NSUInteger)toIndex;

// 指定切换到toIndex时调用，通知外部即将从fromIndex页面切换到toIndex页面，showPageAtIndex:(NSInteger)index animated:(BOOL)animated 开始时调用
- (void)pageViewController:(QNBPageViewController *)pageViewController
                       willLeaveFromIndex:(NSUInteger)fromIndex
                                 toIndex:(NSUInteger)toIndex
                                animated:(BOOL)animated;

// 指定切换到toIndex时调用，通知外部已经从fromIndex页面切换到toIndex页面 showPageAtIndex:(NSInteger)index animated:(BOOL)animated 结束时调用
- (void)pageViewController:(QNBPageViewController *)pageViewController
                        DidLeaveFromIndex:(NSUInteger)fromIndex
                                 toIndex:(NSUInteger)toIndex;

@end


@interface QNBPageViewController : UIViewController

@property (nonatomic, weak) id<QNBPageViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<QNBPageViewControllerDelegate> delegate;

@property (nonatomic, assign) NSUInteger controllerCacheCount_max;

// 当数据准备好后调用该接口，用以更新pageViewController的Child Controller个数、页面Size等属性
- (void)reloadDatas;

- (void)showPageAtIndex:(NSInteger)index animated:(BOOL)animated;

@end
