//
//  QNBPromptManager.m
//  QLBaseKit
//
//  Created by Norcy on 2017/4/10.
//  Copyright © 2017年 Norcy. All rights reserved.
//

#import "QNBPromptManager.h"
#import "QLBaseKit.h"
#import "UIDevice-Hardware.h"

static MBProgressHUD *_hudView = nil;

@implementation QNBPromptManager

+ (BOOL)isShowingHUDPromptView
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *view = [keyWindow viewWithTag:MBProgressHUDViewTag];
    if (view && [view isKindOfClass:[MBProgressHUD class]])
    {
        return YES;
    }
    return NO;
}

/**
 * 隐藏window上已经出现的toast
 */
+ (void)HideHUDPromptView
{
    [self HideHUDPromptViewWithParentView:[[UIApplication sharedApplication] keyWindow]];
}

/**
 某些View是找不到其Window的，因此可能需要手动指定其父View
 @param parentView 可能加了MBProgressHUD的父View
 */
+ (void)HideHUDPromptViewWithParentView:(UIView *)parentView
{
    UIView *view = [parentView viewWithTag:MBProgressHUDViewTag];
    if (view && [view isKindOfClass:[MBProgressHUD class]])
    {
        [((MBProgressHUD *)view) hide:NO];
    }
}

/**
 * 默认的纯文本toast方法（offsetX=0,offsetY=0,delay=3.0,userIteraction = YES）
 * 其他可参见ShowHUDPrompt: withParentViewController: withIcon: 和 ShowHUDPrompt: withParentViewController: icon: offsetX: offsetY: delay: withInteractionEnabed:
 */
+ (void)ShowHUDPrompt:(NSString *)promptText withParentViewController:(UIViewController *)parentViewController
{
    // 4.9有带delay的均关闭enabled，这样底View可以继续响应用户的操作，不会卡界面的感觉，jiachunke
    [self ShowHUDPrompt:promptText withParentViewController:parentViewController icon:nil offsetX:0 offsetY:0 delay:3.0 withInteractionEnabed:NO];
}

/**
 * 默认的上方带图标纯文本的Toast方法（offsetX=0,offsetY=0,delay=3.0,userIteraction = YES，icon可配置) 4.8.0版本未使用 icon处于label上方
 * 其他可参见ShowHUDPrompt: withParentViewController: 和 ShowHUDPrompt: withParentViewController: icon: offsetX: offsetY: delay: withInteractionEnabed:
 */
+ (void)ShowHUDPrompt:(NSString *)promptText withParentViewController:(UIViewController *)parentViewController withIcon:(NSString *)iconName
{
    // 4.9有带delay的均关闭enabled，这样底View可以继续响应用户的操作，不会卡界面的感觉，jiachunke
    [self ShowHUDPrompt:promptText withParentViewController:parentViewController icon:iconName offsetX:0 offsetY:0 delay:3.0 withInteractionEnabed:NO];
}

/**
 * 指定的可带图标的纯文本Toast方法（offsetX,offsetY,delay,userIteraction,icon可配置)
 * 其他可参见ShowHUDPrompt: withParentViewController: 和 ShowHUDPrompt: withParentViewController: icon:
 */
+ (void)ShowHUDPrompt:(NSString *)promptText withParentViewController:(UIViewController *)parentViewController
                 icon:(NSString *)iconName
              offsetX:(NSInteger)offsetX
              offsetY:(NSInteger)offsetY
                delay:(NSTimeInterval)delay
withInteractionEnabed:(BOOL)isEnabled
{
//    if (parentViewController == nil || !parentViewController.view.viewController || ![parentViewController isKindOfClass:[UIViewController class]])
//    {
//        return;
//    }
    [self HideHUDPromptView];

    //避免view为空引起的expection
    if (!parentViewController.view)
    {
        return;
    }

    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:parentViewController.view];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
    
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.multiLine = YES;
    HUD.removeFromSuperViewOnHide = YES;
    HUD.labelText = promptText;
    HUD.disappearWhenTouchScreen = YES;
    HUD.userInteractionEnabled = isEnabled;
    HUD.xOffset = offsetX;
    HUD.yOffset = offsetY;
    // 为了避免特殊情况，无法取到子controller而导致弹toast不再屏幕的最前方，统一将toast加在window上  alicejhchen (2016-01-15)
    [parentViewController.view addSubview:HUD];
    [parentViewController.view bringSubviewToFront:HUD];
    //    [parentViewController.view.window addSubview:HUD];
    [HUD show:YES];
    [HUD hide:YES afterDelay:delay];
}

// 弹的toast，在用户点击屏幕时toast消失 V5.0 alicejhchen (2016-07-26)
+ (void)ShowHUDPrompt:(NSString *)promptText withCustomView:(UIView *)view
{
    [self ShowHUDPrompt:promptText withCustomView:view offsetX:0 offsetY:0];
}

+ (void)ShowHUDPrompt:(NSString *)promptText withCustomView:(UIView *)view offsetX:(NSInteger)offsetX offsetY:(NSInteger)offsetY
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    __block UIView *HUDPromptTmpParentView = nil;
    HUDPromptTmpParentView = [[UIView alloc] initWithFrame:window.bounds];
    HUDPromptTmpParentView.backgroundColor = [UIColor clearColor];
    HUDPromptTmpParentView.autoresizesSubviews = YES;
    HUDPromptTmpParentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [window addSubview:HUDPromptTmpParentView];

    //iOS7及以下在Window上显示toast存在翻转的问题，添加保护
    UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (UIDeviceOrientationIsLandscape(orientation) &&
        ![UIDevice isIOS8OrLatter] &&
        [window isKindOfClass:[UIWindow class]])
    {
        HUDPromptTmpParentView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    }

    [self ShowHUDPrompt:promptText
                        parentWindow:HUDPromptTmpParentView
                      withCustomView:nil
                             offsetX:offsetX
                             offsetY:offsetY
                      hideCompletion:^{
                          [HUDPromptTmpParentView removeFromSuperview];
                          HUDPromptTmpParentView = nil;
                      }];
}

/**
 *在指定的view上显示定制的Toast,completion在toast消失时被调用，用于处理业务层的定制操作
 *zhangliao(2016/04/20 V4.8.5)
 */
+ (void)ShowHUDPrompt:(NSString *)promptText parentWindow:(UIView *)window withCustomView:(UIView *)view hideCompletion:(MBProgressHUDHideDoneCompletion)completion
{
    [self ShowHUDPrompt:promptText parentWindow:window withCustomView:view offsetX:0 offsetY:0 hideCompletion:completion];
}

+ (void)ShowHUDPrompt:(NSString *)promptText parentWindow:(UIView *)window withCustomView:(UIView *)view offsetX:(NSInteger)offsetX offsetY:(NSInteger)offsetY hideCompletion:(MBProgressHUDHideDoneCompletion)completion
{
    //为了保证弹出的Toast在shareAlertView之上，这里采用直接初始化并加在[QAHAlertView keyWindow]上的方式
    [self HideHUDPromptView];

    //这里初始化一个targetView主要是为了兼容initWithView初始化方法
    UIView *targetView = [[UIView alloc] initWithFrame:window.bounds];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:targetView];

    UIView *curCustomView = view;
    if (!curCustomView)
    {
        curCustomView = [[UIImageView alloc] initWithImage:nil];
        curCustomView.userInteractionEnabled = NO;
    }

    HUD.customView = curCustomView;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.hideDoneCompletion = completion;
    HUD.multiLine = YES;
    HUD.removeFromSuperViewOnHide = YES;
    HUD.labelText = promptText;
    HUD.disappearWhenTouchScreen = YES;
    HUD.userInteractionEnabled = YES;
    HUD.tag = MBProgressHUDViewTag;
    HUD.xOffset = offsetX;
    HUD.yOffset = offsetY;

    if (YES == HUD.customView.userInteractionEnabled)
    {
        [HUD bringSubviewToFront:HUD.customView];
    }

    [window addSubview:HUD];
    [window bringSubviewToFront:HUD];
    [HUD show:NO];
    [HUD hide:YES afterDelay:3.0];
}

/**
 * default the image icon is above the label, the function is to adapt the icon on the left of the label  ---  icon在label的左侧的提示
 */
#define LARGE_ICON_SIZE 30.0
#define SMALL_ICON_SIZE 25.0
#define ICON_SPACE 10.0
+ (void)ShowHUDPrompt:(NSString *)promptText withParentViewController:(UIViewController *)parentViewController withLeftIcon:(NSString *)iconName
{

    [self HideHUDPromptView];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:parentViewController.view];

    CGFloat maxLabelWidth = 190;
    CGFloat maxLabelHeight = ceilf([UIFont systemFontOfSize:14].lineHeight) * 2;
    CGFloat singleLabelLineHeight = ceilf([UIFont systemFontOfSize:14].lineHeight);

    UIView *boundView = [[UIView alloc] initWithFrame:CGRectZero];
    boundView.backgroundColor = [UIColor clearColor];

    UIImageView *iconView = nil;

    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.text = promptText;
    textLabel.numberOfLines = 1;

    CGFloat contentWidth = 0;
    CGRect estimateSize = [promptText boundingRectWithSize:CGSizeMake(maxLabelWidth * 2, singleLabelLineHeight) options:NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : textLabel.font } context:nil];
    if (estimateSize.size.width > maxLabelWidth)
    { //两行

        if ([iconName length] > 0)
        {
            iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (maxLabelHeight - LARGE_ICON_SIZE) / 2, LARGE_ICON_SIZE, LARGE_ICON_SIZE)];
            iconView.image = [UIImage imageNamed:iconName];
            iconView.contentMode = UIViewContentModeScaleAspectFill;
            contentWidth += iconView.frame.size.width;
            contentWidth += ICON_SPACE;
            [boundView addSubview:iconView];
        }
        textLabel.numberOfLines = 2;
        CGRect newEstimateSize = [promptText boundingRectWithSize:CGSizeMake(maxLabelWidth, maxLabelHeight) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : textLabel.font } context:nil];
        textLabel.frame = CGRectMake(contentWidth, 0, newEstimateSize.size.width, newEstimateSize.size.height);
        contentWidth += textLabel.frame.size.width;
        [boundView addSubview:textLabel];
        boundView.frame = CGRectMake(0, 0, contentWidth, maxLabelHeight);
    }
    else
    { // 一行

        if ([iconName length] > 0)
        {
            iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SMALL_ICON_SIZE, SMALL_ICON_SIZE)];
            [iconView setImage:[UIImage imageNamed:iconName]];
            iconView.contentMode = UIViewContentModeScaleAspectFill;
            contentWidth += iconView.frame.size.width;
            contentWidth += ICON_SPACE;
            [boundView addSubview:iconView];
        }
        textLabel.frame = CGRectMake(contentWidth, (SMALL_ICON_SIZE - singleLabelLineHeight) / 2, estimateSize.size.width, singleLabelLineHeight);
        contentWidth += textLabel.frame.size.width;
        [boundView addSubview:textLabel];
        boundView.frame = CGRectMake(0, 0, contentWidth, SMALL_ICON_SIZE);
        boundView.backgroundColor = [UIColor clearColor];
    }

    HUD.customView = boundView;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.removeFromSuperViewOnHide = YES;
    HUD.labelText = nil;
    HUD.detailsLabelText = nil;
    HUD.userInteractionEnabled = NO;
    HUD.tag = MBProgressHUDViewTag;
    [parentViewController.view addSubview:HUD];
    [HUD show:YES];
    [HUD hide:YES afterDelay:3.0];
}

+ (void)showHUDWithTip:(BOOL)bShow tip:(NSString *)aTips withHasLoadingActivity:(BOOL)hasLoadingActivity containerView:(UIView *)containerView
{
    if (nil == containerView)
    {
        return;
    }

    if (bShow)
    {
        if (!_hudView)
        {
            _hudView = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, [QLBaseKit getScreenWidth], [QLBaseKit getScreenHeight])];
            _hudView.removeFromSuperViewOnHide = YES;
        }
        
        _hudView.hidden = NO;
        _hudView.frame = containerView.bounds;
        [containerView addSubview:_hudView];
    }
    else
    {
        _hudView.hidden = YES;
        [_hudView hide:NO];
        return;
    }
    
    if (hasLoadingActivity)
    {
        _hudView.customView = nil;
        _hudView.mode = MBProgressHUDModeIndeterminate;
        _hudView.disappearWhenTouchScreen = NO;
    }
    else
    {
        _hudView.customView = [[UIImageView alloc] initWithImage:nil];
        _hudView.mode = MBProgressHUDModeCustomView;
        _hudView.disappearWhenTouchScreen = YES;
        [_hudView cancelPreviousDelayHide];
        [_hudView hide:YES afterDelay:3.0];
    }
    
    _hudView.labelText = aTips;
    
    [_hudView show:YES];
}

+ (BOOL)updateHUDViewLocation:(UIView *)newParentView
{
    if ([self activityHUDShowing])
    {
        [_hudView removeFromSuperview];
        _hudView.hidden = NO;
        _hudView.frame = newParentView.bounds;
        [newParentView addSubview:_hudView];
        [_hudView show:YES];
        return YES;
    }
    return NO;
}

+ (BOOL)activityHUDShowing
{
    return _hudView && _hudView.superview && !_hudView.hidden;
}
@end
