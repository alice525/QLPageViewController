//
//  QLPageViewController.m
//  QLPageViewController
//
//  Created by alicejhchen on 17/5/30.
//  Copyright © 2017年 tencentVideo. All rights reserved.
//

#import "QNBPageViewController.h"
#import "QLPageScrollView.h"

typedef NS_ENUM(NSInteger, QNBPageScrollDirection) {
    QNBPageScrollDirectionLeft = 1,
    QNBPageScrollDirectionRight = 2,
};

@interface QNBPageViewController () <UIScrollViewDelegate, NSCacheDelegate> {
    struct {
        unsigned int willTransitionFromIndex:1;
        unsigned int didTransitionFromIndex:1;
        unsigned int willLeaveFromIndex:1;
        unsigned int didLeaveFromIndex:1;
    } _pageViewControllerDelegateFlags;
}

@property (nonatomic, strong) QLPageScrollView *pageScrollView;

@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, assign) CGSize pageSize;

@property (nonatomic, assign) NSInteger lastSelectIndex;
@property (nonatomic, assign) NSInteger curSelectIndex;
@property (nonatomic, assign) NSInteger guessToIndex;
@property (nonatomic, assign) CGFloat originOffsetX;

@property (nonatomic, strong) NSCache<NSNumber *, UIViewController *> *controllerCache;

@end

@implementation QNBPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self __configScrollView];
    
    _controllerCache = [[NSCache alloc] init];
    _controllerCache.countLimit = 5;
    _controllerCache.delegate = self;
    
    _originOffsetX = 0.0;
    
    [self reloadDatas];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)viewDidLayoutSubviews {

}

- (void)viewWillLayoutSubviews {
    _pageScrollView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame)-_pageSize.height, _pageSize.width, _pageSize.height);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_pageCount > 0) {
        [self showPageAtIndex:0 animated:NO];
    }
}

-(BOOL) shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (void)reloadDatas {
    
    [self __initialize];
    
    self.pageCount = [self.dataSource numberOfControllersInPageViewController:self];
    self.pageSize = [self.dataSource sizeOfOnePageInPageViewController:self];
    
    if (self.pageCount > 0) {
        _pageScrollView.contentSize = CGSizeMake(self.pageSize.width * self.pageCount, self.pageSize.height);
        
    } else {
        _pageScrollView.contentSize = CGSizeMake(0, self.pageSize.height);
    }
    
    for (UIView *view in _pageScrollView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)showPageAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (index < 0 || index >= self.pageCount) {
        return;
    }
    
    self.lastSelectIndex = self.curSelectIndex;
    self.curSelectIndex = index;
    
    if (_pageScrollView.frame.size.width <= 0 || _pageScrollView.contentSize.width <= 0) {
        return;
    }
    
    if (_lastSelectIndex == _curSelectIndex) {
        return;
    }
    
    if (_pageViewControllerDelegateFlags.willLeaveFromIndex) {
        [_delegate pageViewController:self willLeaveFromIndex:_lastSelectIndex toIndex:_curSelectIndex animated:animated];
    }
    
    [self __addChildControllerWithIndex:_curSelectIndex];
    
    [self __handleWhenScrollingBegin:animated];
    
    [self __changePageAnimation:animated];
    
}

- (void)setControllerCacheCount_max:(NSUInteger)controllerCacheCount_max {
    _controllerCache.countLimit = controllerCacheCount_max;
}

- (NSUInteger)controllerCacheCount_max {
    return _controllerCache.countLimit;
}

- (void)setDelegate:(id<QNBPageViewControllerDelegate>)delegate {
    _delegate = delegate;
    
    if (delegate == nil) {
        memset(&_pageViewControllerDelegateFlags, 0, sizeof(_pageViewControllerDelegateFlags));
    } else {
        _pageViewControllerDelegateFlags.willTransitionFromIndex = [delegate respondsToSelector:@selector(pageViewController:willTransitionFromIndex:toIndex:)];
        _pageViewControllerDelegateFlags.didTransitionFromIndex = [delegate respondsToSelector:@selector(pageViewController:DidTransitionFromIndex:toIndex:)];
        _pageViewControllerDelegateFlags.willLeaveFromIndex = [delegate respondsToSelector:@selector(pageViewController:willLeaveFromIndex:toIndex:animated:)];
        _pageViewControllerDelegateFlags.didLeaveFromIndex = [delegate respondsToSelector:@selector(pageViewController:DidLeaveFromIndex:toIndex:)];
    }
}

#pragma mark - privates

- (void)__initialize {
    _lastSelectIndex = -1;
    _curSelectIndex = -1;
}

- (void)__configScrollView {
    _pageScrollView = [[QLPageScrollView alloc] initWithFrame:self.view.bounds];
    _pageScrollView.showsVerticalScrollIndicator = NO;
    _pageScrollView.showsHorizontalScrollIndicator = NO;
    _pageScrollView.delegate = self;
    _pageScrollView.pagingEnabled = YES;
    _pageScrollView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_pageScrollView];
}

- (UIViewController *)__controllerAtIndex:(NSInteger)index {
    
    if (index < 0 || index >= _pageCount) {
        return nil;
    }
    
    UIViewController *viewCtl = [_controllerCache objectForKey:@(index)];
    
    if (!viewCtl) {
        viewCtl = [self.dataSource pageViewController:self controllerAtIndex:index];
        
        //NSLog(@"controllerAtIndex :%p  index: %zd", viewCtl, index);
        
        if (viewCtl) {
            [_controllerCache setObject:viewCtl forKey:@(index)];
        }
    }
    
    return viewCtl;
}

- (void)__addChildControllerWithIndex:(NSInteger)index {
    if (index < 0 || index >= self.pageCount) {
        return;
    }
    
    UIViewController *VC = [self __controllerAtIndex:index];
    
    if (VC) {
        CGRect frame = [self __calcViewControllerFrameWithIndex:index];
        
        [self __addChildViewController:VC inView:_pageScrollView withFrame:frame];
    }
}

- (void)__handleWhenScrollingBegin:(BOOL)animated {
    
    if (_pageScrollView.frame.size.width <= 0 || _pageScrollView.contentSize.width <= 0) {
        return;
    }
    
    [[self __controllerAtIndex:self.curSelectIndex] beginAppearanceTransition:YES animated:animated];
    
    if (_curSelectIndex != _lastSelectIndex &&
        _lastSelectIndex >= 0 && _lastSelectIndex < _pageCount) {
        [[self __controllerAtIndex:_lastSelectIndex] beginAppearanceTransition:NO animated:animated];
    }
}

- (void)__handleWhenScrolling:(BOOL)animated {
    if (_pageScrollView.frame.size.width <= 0 || _pageScrollView.contentSize.width <= 0) {
        return;
    }
    
    CGPoint offset = [self __calcOffsetWithIndex:self.curSelectIndex maxWidth:_pageScrollView.contentSize.width];
    self.pageScrollView.contentOffset = offset;
}

- (void)__handleWhenScrollingEnd:(BOOL)animated {
    if (_pageScrollView.frame.size.width <= 0 || _pageScrollView.contentSize.width <= 0) {
        return;
    }
    
    [[self __controllerAtIndex:_curSelectIndex] endAppearanceTransition];
    
    if (_curSelectIndex != _lastSelectIndex &&
        _lastSelectIndex >= 0 && _lastSelectIndex < _pageCount) {
        [[self __controllerAtIndex:_lastSelectIndex] endAppearanceTransition];
    }
    
    if (_pageViewControllerDelegateFlags.didLeaveFromIndex) {
        [_delegate pageViewController:self DidLeaveFromIndex:_lastSelectIndex toIndex:_curSelectIndex];
    }
}

- (CGPoint)__calcOffsetWithIndex:(NSInteger)index maxWidth:(CGFloat)maxWidth {
    CGFloat offsetX = index * _pageSize.width;
    
    if (offsetX < 0) {
        offsetX = 0;
    }
    
    if (maxWidth > 0 && offsetX > maxWidth - _pageSize.width) {
        offsetX = maxWidth - _pageSize.width;
    }
    
    return CGPointMake(offsetX, 0);
}

- (NSInteger)__calcIndexWithOffset:(CGFloat)offset width:(CGFloat)pageWidth {
    NSInteger index = (NSInteger)(offset/pageWidth);
    
    if (index < 0) {
        index = 0;
    }
    
    if (index >= _pageCount) {
        index = _pageCount;
    }
    
    return index;
}

- (CGRect)__calcViewControllerFrameWithIndex:(NSInteger)index {
    CGFloat originX = index * _pageSize.width;
    
    return CGRectMake(originX, 0, _pageSize.width, CGRectGetHeight(_pageScrollView.frame));
}

- (void)__addChildViewController:(UIViewController *)controller inView:(UIView *)parentView withFrame:(CGRect)frame {
    
    BOOL containsVC = [self.childViewControllers containsObject:controller];
    
    if (!containsVC) {
        [self addChildViewController:controller];
    }
    
    controller.view.frame = frame;
    
    if (![parentView.subviews containsObject:controller.view]) {
        [parentView addSubview:controller.view];
    }
    
    if (!containsVC) {
        [controller didMoveToParentViewController:self];
    }
}

- (void)__removeFromParentViewControllerForController:(UIViewController *)controller {
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
}

- (void)__changePageAnimation:(BOOL)animated {
    
    if (_lastSelectIndex == _curSelectIndex) {
        return;
    }
    
    if (animated) {
        QNBPageScrollDirection direction = (self.lastSelectIndex < self.curSelectIndex)? QNBPageScrollDirectionRight : QNBPageScrollDirectionLeft;
        UIView *lastView = [self __controllerAtIndex:_lastSelectIndex].view;
        UIView *currentView = [self __controllerAtIndex:_curSelectIndex].view;
        
        [lastView.layer removeAllAnimations];
        [currentView.layer removeAllAnimations];
        
        CGPoint lastView_StartOrigin = lastView.frame.origin;
        CGPoint currentView_StartOrigin = lastView_StartOrigin;
        
        CGPoint lastView_AnimateToOrigin = lastView_StartOrigin;
        CGPoint currentView_AnimateToOrigin = lastView_StartOrigin;
        
        if (direction == QNBPageScrollDirectionLeft) {
            currentView_StartOrigin.x -= _pageSize.width;
            lastView_AnimateToOrigin.x += _pageSize.width;
        } else {
            currentView_StartOrigin.x += _pageSize.width;
            lastView_AnimateToOrigin.x -= _pageSize.width;
        }
        
        CGPoint lastView_EndOrigin = lastView.frame.origin;
        CGPoint currentView_EndOrigin = currentView.frame.origin;
        
        lastView.frame = CGRectMake(lastView_StartOrigin.x, lastView_StartOrigin.y, _pageSize.width, _pageSize.height);
        currentView.frame = CGRectMake(currentView_StartOrigin.x, currentView_StartOrigin.y, _pageSize.width, _pageSize.height);
        
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            lastView.frame = CGRectMake(lastView_AnimateToOrigin.x, lastView_AnimateToOrigin.y, _pageSize.width, _pageSize.height);
            currentView.frame = CGRectMake(currentView_AnimateToOrigin.x, currentView_AnimateToOrigin.y, _pageSize.width, _pageSize.height);
        } completion:^(BOOL finished) {
            if (finished) {
                lastView.frame = CGRectMake(lastView_EndOrigin.x, lastView_EndOrigin.y, _pageSize.width, _pageSize.height);
                currentView.frame = CGRectMake(currentView_EndOrigin.x, currentView_EndOrigin.y, _pageSize.width, _pageSize.height);
                
                [weakSelf __handleWhenScrolling:animated];
                [weakSelf __handleWhenScrollingEnd:animated];
            }
        }];
    } else {
        [self __handleWhenScrolling:animated];
        [self __handleWhenScrollingEnd:animated];
    }
}


/**
 用户拖拽导致切换child controller停止时，在此处理child controller的生命周期

 @param scrollView self.pageScrollView
 */
- (void)__updatePageViewAfterDragging:(UIScrollView *)scrollView {
    NSInteger newIndex = [self __calcIndexWithOffset:scrollView.contentOffset.x width:_pageSize.width];
    NSInteger oldIndex = _curSelectIndex;
    _curSelectIndex = newIndex;
    _lastSelectIndex = oldIndex;
    
    NSLog(@"updatePageViewAfterTracking OffsetX:%.2f newIndex:%zd oldIndex:%zd", scrollView.contentOffset.x, newIndex, oldIndex);
    
    if (newIndex != oldIndex) {
        
        UIViewController *newVC = [self __controllerAtIndex:newIndex];
        UIViewController *oldVC = [self __controllerAtIndex:oldIndex];
        
        NSAssert(newVC, @"newVC nil");
        NSAssert(oldVC, @"oldVC nil");
        
        [[self __controllerAtIndex:newIndex] endAppearanceTransition];
        [[self __controllerAtIndex:oldIndex] endAppearanceTransition];
        
        //NSLog(@"updatePageViewAfterTracking newIndex != oldIndex newIndex: %zd oldIndex: %zd", newIndex, oldIndex);
    } else if (_guessToIndex >= 0 && _guessToIndex < _pageCount) {
        
        UIViewController *newVC = [self __controllerAtIndex:newIndex];
        UIViewController *guessVC = [self __controllerAtIndex:_guessToIndex];
        
        [newVC beginAppearanceTransition:YES animated:YES];
        [newVC endAppearanceTransition];
        
        // 当预测的页面不是最后显示的页面时，要调用预测页面的disapear
        if (_guessToIndex != newIndex) {
            [guessVC beginAppearanceTransition:NO animated:YES];
            [guessVC endAppearanceTransition];
        }
        
        //NSLog(@"updatePageViewAfterTracking newIndex == oldIndex newIndex: %zd guessIndex: %zd", newIndex, _guessToIndex);
    }
    
    //NSLog(@"DidTransitionFromIndex from:%zd to:%zd", oldIndex, _curSelectIndex);
    if (_pageViewControllerDelegateFlags.didTransitionFromIndex) {
        [_delegate pageViewController:self DidTransitionFromIndex:oldIndex toIndex:_curSelectIndex];
    }
    
    self.originOffsetX = scrollView.contentOffset.x;
    self.guessToIndex = _curSelectIndex;
}

#pragma mark - UIScrollViewDelegate

/**
 用户拖拽造成的页面切换，child controller的生命周期在此触发

 @param scrollView self.pageScrollView
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    /* 只有用户拖拽的滚动才触发该生命周期处理逻辑，通过代码更新scrollView的contentOffset也会调用scrollDidScroll，
       此时不应该走入该逻辑
    */
    if (scrollView == _pageScrollView && scrollView.isDragging) {
        
        NSInteger lastGuessIndex = _guessToIndex >= 0 ? _guessToIndex : _curSelectIndex;
        if (lastGuessIndex >= _pageCount) {
            lastGuessIndex = _pageCount-1;
        }
        
        CGFloat offsetX = scrollView.contentOffset.x;
        
        if (_originOffsetX < offsetX) {
            _guessToIndex = (NSInteger)(ceilf(offsetX / _pageSize.width));
        } else if (_originOffsetX > offsetX) {
            _guessToIndex = (NSInteger)(floorf(offsetX / _pageSize.width));
        }
        
        NSLog(@"scrollViewDidScroll guessToIndex: %zd lastGuessIndex: %zd curIndex:%zd offsetX: %.2f originOffsetX: %.2f isDecelerating:%zd", _guessToIndex, lastGuessIndex, _curSelectIndex, offsetX, _originOffsetX, scrollView.isDecelerating);
        
        if ((_guessToIndex != _curSelectIndex && !scrollView.isDecelerating) || scrollView.isDecelerating) {
            if (_guessToIndex != lastGuessIndex &&
                _guessToIndex >= 0 && _guessToIndex < _pageCount) {
                
                //NSLog(@"willTransitionFromIndex from:%zd to:%zd", lastGuessIndex, _guessToIndex);
                if (_pageViewControllerDelegateFlags .willTransitionFromIndex) {
                    [_delegate pageViewController:self willTransitionFromIndex:lastGuessIndex toIndex:_guessToIndex];
                }
                
                [self __addChildControllerWithIndex:_guessToIndex];
                [[self __controllerAtIndex:_guessToIndex] beginAppearanceTransition:YES animated:YES];
                
                //NSLog(@"scrollViewDidScroll guessToIndex: %zd", _guessToIndex);
                
                if (lastGuessIndex == _curSelectIndex) {
                    [[self __controllerAtIndex:_curSelectIndex] beginAppearanceTransition:NO animated:YES];
                    
                    //NSLog(@"scrollViewDidScroll _curSelectIndex: %zd", _curSelectIndex);
                }
                
                if (lastGuessIndex != _curSelectIndex &&
                    lastGuessIndex >= 0 && lastGuessIndex < _pageCount) {
                    UIViewController *lastGuessVC = [self __controllerAtIndex:lastGuessIndex];
                    
                    [lastGuessVC beginAppearanceTransition:NO animated:YES];
                    [lastGuessVC endAppearanceTransition];
                    
                    //NSLog(@"scrollViewDidScroll lastGuessIndex: %zd", lastGuessIndex);
                }
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    /* 上一次滑动结束了才能重置状态，否则滑动停止时调用__updatePageViewAfterTracking方法，
       guessToIndex错误，导致生命周期会紊乱
     */
    if (!scrollView.decelerating) {
        self.guessToIndex = _curSelectIndex;
        self.originOffsetX = scrollView.contentOffset.x;
    }
    
    //NSLog(@"scrollViewWillBeginDragging curIndex: %zd decelerating: %zd", _curSelectIndex, scrollView.decelerating);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        //NSLog(@"scrollViewDidEndDragging");
        [self __updatePageViewAfterDragging:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //NSLog(@"scrollViewDidEndDecelerating");
    [self __updatePageViewAfterDragging:scrollView];
}


@end
