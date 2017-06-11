//
//  QNBPromptManager.h
//  QLBaseKit
//
//  Created by Norcy on 2017/4/10.
//  Copyright © 2017年 Norcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QLMBProgressHUD.h"

@interface QNBPromptManager : NSObject
+ (BOOL)isShowingHUDPromptView;

//modified by ericlezhou  2016-02-26
/**
 * 隐藏window上已经出现的toast
 */
+ (void)HideHUDPromptView;

/**
 某些View是找不到其Window的，因此可能需要手动指定其父View
 @param parentView 可能加了MBProgressHUD的父View
 */
+ (void)HideHUDPromptViewWithParentView:(UIView *)parentView;

/**
 * 默认的纯文本toast方法（offsetX=0,offsetY=0,delay=3.0,而且userIteraction = YES）
 */
+ (void)ShowHUDPrompt:(NSString *)promptText withParentViewController:(UIViewController *)parentViewController;
/**
 * 默认的上方带图标的Toast方法（offsetX=0,offsetY=0,delay=3.0,而且userIteraction = YES）
 */
+ (void)ShowHUDPrompt:(NSString *)promptText withParentViewController:(UIViewController *)parentViewController withIcon:(NSString *)iconName;

/**
 *在指定的view上显示定制的Toast,completion在toast消失时被调用，用于处理业务层的定制操作
 *zhangliao(2016/04/20 V4.8.5)
 */
+ (void)ShowHUDPrompt:(NSString *)promptText parentWindow:(UIView *)window withCustomView:(UIView *)view hideCompletion:(MBProgressHUDHideDoneCompletion)completion;

//可以指定toast的位置
+ (void)ShowHUDPrompt:(NSString *)promptText parentWindow:(UIView *)window withCustomView:(UIView *)view offsetX:(NSInteger)offsetX offsetY:(NSInteger)offsetY hideCompletion:(MBProgressHUDHideDoneCompletion)completion;

/**
 * 指定的可带图标的纯文本Toast方法（offsetX,offsetY,delay,userIteraction,icon可配置)
 * 其他可参见ShowHUDPrompt: withParentViewController: 和 ShowHUDPrompt: withParentViewController: icon:
 * 当isEnabled为NO的时候，HUD的userInteractionEnabled属性是NO，此时针对缓存剧集时点击弹出toast的情况，其他UI页面弹出的toast的userInteractionEnabled属性默认是YES。   by ericlezhou 2016-02-25
 */
+ (void)ShowHUDPrompt:(NSString *)promptText withParentViewController:(UIViewController *)parentViewController
                        icon:(NSString *)iconName
                     offsetX:(NSInteger)offsetX
                     offsetY:(NSInteger)offsetY
                       delay:(NSTimeInterval)delay
       withInteractionEnabed:(BOOL)isEnabled;

// 带图标居左显示的toast -- 针对VIP会员提示
+ (void)ShowHUDPrompt:(NSString *)promptText withParentViewController:(UIViewController *)parentViewController withLeftIcon:(NSString *)iconName;

// 5.0 扩展接口，支持指定containerView
+ (void)showHUDWithTip:(BOOL)bShow tip:(NSString *)aTips withHasLoadingActivity:(BOOL)hasLoadingActivity containerView:(UIView *)containerView;

// 弹的toast，在用户点击屏幕时toast消失  alicejhchen (2016-07-26)
+ (void)ShowHUDPrompt:(NSString *)promptText withCustomView:(UIView *)view;

+ (void)ShowHUDPrompt:(NSString *)promptText withCustomView:(UIView *)view offsetX:(NSInteger)offsetX offsetY:(NSInteger)offsetY;

// 判断是否showing
+ (BOOL)activityHUDShowing;
// 根据 newParentView 刷新HUD位置
+ (BOOL)updateHUDViewLocation:(UIView *)newParentView;
@end
