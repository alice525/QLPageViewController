//
//  SIAlertView.h
//  SIAlertView
//
//  Created by Kevin Cao on 13-4-29.
//  Copyright (c) 2013年 Sumi Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const SIAlertViewWillShowNotification;
extern NSString *const SIAlertViewDidShowNotification;
extern NSString *const SIAlertViewWillDismissNotification;
extern NSString *const SIAlertViewDidDismissNotification;

typedef NS_ENUM(NSInteger, SIAlertViewButtonType) {
    SIAlertViewButtonTypeDefault = 0,
    SIAlertViewButtonTypeDestructive,
    SIAlertViewButtonTypeCancel
};

typedef NS_ENUM(NSInteger, SIAlertViewBackgroundStyle) {
    SIAlertViewBackgroundStyleGradient = 0,
    SIAlertViewBackgroundStyleSolid,
};

typedef NS_ENUM(NSInteger, SIAlertViewTransitionStyle) {
    SIAlertViewTransitionStyleSlideFromBottom = 0,
    SIAlertViewTransitionStyleSlideFromTop,
    SIAlertViewTransitionStyleFade,
    SIAlertViewTransitionStyleBounce,
    SIAlertViewTransitionStyleDropDown
};

typedef NS_ENUM(NSInteger, SIAlertViewAccesseryViewStyle) {
    SIAlertViewAccessaryViewStyleDefault = 0,  // 上图下文
    SIAlertViewAccessaryViewStyleLeft,         // 左图右文
};

typedef NS_ENUM(NSInteger, SIAlertViewBackgroundViewStyle) {
    SIAlertViewBackgroundViewStyleDefault = 0,  // 默认背景
    SIAlertViewBackgroundViewStyleTranslucent,         // 透明背景
};

typedef void (^SIAlertViewButtonBlock)();

#define kQLAlertEnable3GTips QLLangString(@"温馨提示：运营商网络下载可能会导致超额流量，确认开启？")
#define kQLAlertEnableOpenPush QLLangString(@"iOS系统设置[通知]中腾讯视频项未打开,无法收到推送,请先去设置。")
#define kQLAlertNotSpaceTips QLLangString(@"缓存文件已添加，下载完成后预计剩余空间不足%dM，为保护您的iPhone，建议整理空间。")


@class SIAlertView;
typedef void(^SIAlertViewHandler)(SIAlertView *alertView);
typedef BOOL(^SIAlertViewBtnHandler)(SIAlertView *alertView, UIButton *button);
typedef BOOL(^SIAlertViewLinkBlock)(NSURL *url);

@interface SIAlertView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) UIView *accesseryView;
@property (nonatomic, assign) BOOL supportClickBGViewDismiss;

@property (nonatomic, assign) SIAlertViewTransitionStyle transitionStyle; // default is SIAlertViewTransitionStyleSlideFromBottom
@property (nonatomic, assign) SIAlertViewBackgroundStyle backgroundStyle; // default is SIAlertViewButtonTypeGradient

@property (nonatomic, copy) SIAlertViewHandler willShowHandler;
@property (nonatomic, copy) SIAlertViewHandler didShowHandler;
@property (nonatomic, copy) SIAlertViewHandler willDismissHandler;
@property (nonatomic, copy) SIAlertViewHandler didDismissHandler;

@property (nonatomic, copy) SIAlertViewLinkBlock linkBlock;

@property (nonatomic, readonly, getter = isVisible) BOOL visible;

@property (nonatomic, strong) UIColor *viewBackgroundColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *titleColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *messageColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *titleFont NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *messageFont NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *buttonFont NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat cornerRadius NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; // default is 2.0
@property (nonatomic, assign) CGFloat shadowRadius NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; // default is 8.0

// default NSTextAlignmentCenter
@property (nonatomic, assign) NSTextAlignment messageTextAligment;

// 文本距Alert边缘距离
@property (nonatomic, assign) CGFloat textDistanceOfEdge; //default is 15.0

@property (nonatomic, assign) SIAlertViewBackgroundViewStyle *backgroundViewStyle;

// init methods
- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message;
- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message accesseryView:(UIView *)accesseryView;
- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message accesseryView:(UIView *)accesseryView accesseryViewStyle:(SIAlertViewAccesseryViewStyle)style;

- (void)addButtonWithTitle:(NSString *)title type:(SIAlertViewButtonType)type handler:(SIAlertViewHandler)handler;
- (void)addButtonWithTitle:(NSString *)title image:(UIImage *)image type:(SIAlertViewButtonType)type customHandler:(SIAlertViewBtnHandler)handler;

- (void)show;
- (void)dismissAnimated:(BOOL)animated;

+ (BOOL)alreadyPopover;
+ (void)dismissAlertView;
+ (SIAlertView *)currentAlertView;

// 0 : 竖屏，  1 : 横屏
- (void)setOrientationMode:(NSInteger)aMode;

// convinient methods
// 普通样式的标题，副标题弹框
- (id)initWithTxt:(NSString *)message
            title:(NSString *)title
      cancelTitle:(NSString *)cancelTitle
      cancelblock:(SIAlertViewButtonBlock)cancelblock
     confirmTitle:(NSString *)confirmTitle
     confirmblock:(SIAlertViewButtonBlock)confirmblock;

// 图片背景定制标题样式的弹框
- (id)initWithTxt:(NSString *)message
       ImgBgTitle:(NSString *)title
      cancelTitle:(NSString *)cancelTitle
      cancelblock:(SIAlertViewButtonBlock)cancelblock
     confirmTitle:(NSString *)confirmTitle
     confirmblock:(SIAlertViewButtonBlock)confirmblock;

// 定制背景图片的确认弹框
- (id)initWithImgBgName:(NSString *)name
      cancelTitle:(NSString *)cancelTitle
      cancelblock:(SIAlertViewButtonBlock)cancelblock
     confirmTitle:(NSString *)confirmTitle
     confirmblock:(SIAlertViewButtonBlock)confirmblock;

// 定制背景图片的确认弹框(背景图片是image对象) add in 5.3,20161119
- (id)initWithImg:(UIImage *)image
            cancelTitle:(NSString *)cancelTitle
            cancelblock:(SIAlertViewButtonBlock)cancelblock
           confirmTitle:(NSString *)confirmTitle
           confirmblock:(SIAlertViewButtonBlock)confirmblock
            style:(SIAlertViewBackgroundViewStyle)style;


// 获取alert的右上角位置  alicejhchen (2016-04-21)
- (CGPoint)getAlertViewTopRight;

+ (void)qlnoticeWithMsg:(NSString*)msg title:(NSString *)strTitle confirmTitle:(NSString *)confirmTitle cancelTitle:(NSString *)cancelTitle;

// 4.9.0加的带对齐风格样式的弹框  elonliu
- (id)initWithTxt:(NSString *)message
            title:(NSString *)title
      cancelTitle:(NSString *)cancelTitle
      cancelblock:(SIAlertViewButtonBlock)cancelblock
     confirmTitle:(NSString *)confirmTitle
     confirmblock:(SIAlertViewButtonBlock)confirmblock
        textAligh:(NSTextAlignment)textAligh;

/**
 *  5.1.0 新增的带链接模式的 SIAlertView 对以下几个新增属性做出说明 (Add by Mark 2016/08/15)
 *
 *  @param linkRange    链接所处的位置
 *  @param linkColor    平常态时，链接的颜色
 *  @param activeColor  点击态时，链接的颜色
 *  @param linkURL      链接的 url
 *  @param linkBlock    链接点击时触发的回调, (return YES) 表示在点击时需要自动消失 
 *
 */
- (id)initWithLinkTxt:(NSString *)message
            linkRange:(NSRange)linkRange
            linkColor:(UIColor *)linkColor
          activeColor:(UIColor *)activeColor
              linkURL:(NSURL *)linkURL
            linkBlock:(SIAlertViewLinkBlock)linkBlock
                title:(NSString *)title
          cancelTitle:(NSString *)cancelTitle
          cancelblock:(SIAlertViewButtonBlock)cancelblock
         confirmTitle:(NSString *)confirmTitle
         confirmblock:(SIAlertViewButtonBlock)confirmblock;

@end
