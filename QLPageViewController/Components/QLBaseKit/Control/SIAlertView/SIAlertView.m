 //
//  SIAlertView.m
//  SIAlertView
//
//  Created by Kevin Cao on 13-4-29.
//  Copyright (c) 2013年 Sumi Interactive. All rights reserved.
//

#import "SIAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIDevice-Hardware.h"
#import "QLHTMLFontLabel.h"
#import "QLHTMLFontTextView.h"
#import "QLAttributedLabel.h"
#import "UITextView+LineSpace.h"

NSString *const SIAlertViewWillShowNotification = @"SIAlertViewWillShowNotification";
NSString *const SIAlertViewDidShowNotification = @"SIAlertViewDidShowNotification";
NSString *const SIAlertViewWillDismissNotification = @"SIAlertViewWillDismissNotification";
NSString *const SIAlertViewDidDismissNotification = @"SIAlertViewDidDismissNotification";

// 宏控制使用不同控件
//#define MESSAGE_USE_LABLE

#define DEBUG_LAYOUT 0

#define MESSAGE_MIN_LINE_COUNT 1
#define MESSAGE_MAX_LINE_COUNT 8
#define GAP 15
#define TITLE_PADDING_TOP 20
#define CANCEL_BUTTON_PADDING_TOP 5
#define CONTENT_PADDING_LEFT 15
#define CONTENT_PADDING_TOP 0
#define CONTENT_PADDING_BOTTOM 0//5
#define BUTTON_HEIGHT 48
#define CONTAINER_WIDTH 298
#define CONTENT_MIN_HEIGHT 110

#define CONTENT_BUTTONS_GAP 20
#define LINE_SPACE 4

#ifndef RGBCOLOR
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#endif

const UIWindowLevel UIWindowLevelSIAlert = 1999.0;  // don't overlap system's alert
const UIWindowLevel UIWindowLevelSIAlertBackground = 1998.0; // below the alert window

@class SIAlertBackgroundWindow;

static NSMutableArray *__si_alert_queue;
static BOOL __si_alert_animating;
static SIAlertBackgroundWindow *__si_alert_background_window;
static SIAlertView *__si_alert_current_view;

@interface SIAlertView () <QLAttributedLabelDelegate>

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, assign, getter = isVisible) BOOL visible;

@property (nonatomic, strong) QLHTMLFontLabel *titleLabel;
#ifdef MESSAGE_USE_LABLE
@property (nonatomic, strong) QLHTMLFontLabel *messageLabel;
#else
@property (nonatomic, strong) QLHTMLFontTextView *messageLabel;
#endif
@property (nonatomic, strong) QLAttributedLabel *attributedLabel;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *lines;

@property (nonatomic, strong) NSString *attributedMessage;
@property (nonatomic, strong) NSURL *linkURL;
@property (nonatomic, assign) NSRange linkRange;
@property (nonatomic, strong) UIColor *linkColor;
@property (nonatomic, strong) UIColor *activeColor;

@property (nonatomic, assign) SIAlertViewAccesseryViewStyle accesseryViewStyle;

//@property (nonatomic, strong) UIView * accesseryView;

@property (nonatomic, assign, getter = isLayoutDirty) BOOL layoutDirty;

+ (NSMutableArray *)sharedQueue;

+ (BOOL)isAnimating;
+ (void)setAnimating:(BOOL)animating;

+ (void)showBackground;
+ (void)hideBackgroundAnimated:(BOOL)animated;

- (void)setup;
- (void)invaliadateLayout;
- (void)resetTransition;

@end

#pragma mark - SIBackgroundWindow

@interface SIAlertBackgroundWindow : UIWindow

@end

@interface SIAlertBackgroundWindow ()

@property (nonatomic, assign) SIAlertViewBackgroundStyle style;

@end

@implementation SIAlertBackgroundWindow

//- (void)dealloc{
//    //TO-DO
//}

- (id)initWithFrame:(CGRect)frame andStyle:(SIAlertViewBackgroundStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        self.style = style;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.windowLevel = UIWindowLevelSIAlertBackground;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (self.style) {
        case SIAlertViewBackgroundStyleGradient:
        {
            size_t locationsCount = 2;
            CGFloat locations[2] = {0.0f, 1.0f};
            CGFloat colors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.75f};
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
            CGColorSpaceRelease(colorSpace);
            
            CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
            CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) ;
            CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            break;
        }
        case SIAlertViewBackgroundStyleSolid:
        {
            [[UIColor colorWithWhite:0 alpha:0.4] set];
            CGContextFillRect(context, self.bounds);
            break;
        }
    }
}

@end

#pragma mark - SIAlertItem

@interface SIAlertItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) SIAlertViewButtonType type;
@property (nonatomic, copy) SIAlertViewHandler action;
@property (nonatomic, copy) SIAlertViewBtnHandler customAction;
@property (nonatomic, strong) UIImage *btnImage;

@end

@implementation SIAlertItem

@end

#pragma mark - SIAlertViewController

@interface SIAlertViewController : UIViewController

@property (nonatomic, strong) SIAlertView *alertView;

// 0 竖屏   1 横屏
@property (nonatomic, assign) NSUInteger orientationMode;

@end

@implementation SIAlertViewController

#pragma mark - View life cycle

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"dealloc...");
}
#endif

- (void)loadView {
    self.view = self.alertView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.alertView setup];
}

// 不自动旋转 hengzhuoliu 20150409
- (BOOL)shouldAutorotate {
//    if ( 0 == _orientationMode ) {
//        return NO;
//    }
    
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.alertView resetTransition];
    [self.alertView invaliadateLayout];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ( _orientationMode == 0 ) {
        // 竖屏
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskLandscape;
}

@end

#pragma mark - SIAlert

@implementation SIAlertView

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"dealloced...");
}
#endif

+ (void)initialize
{
    if (self != [SIAlertView class])
        return;
    
    SIAlertView *appearance = [self appearance];
    appearance.viewBackgroundColor = [UIColor whiteColor];
    appearance.titleColor = [UIColor blackColor];
    appearance.messageColor = RGBCOLOR(0x22, 0x22, 0x22);
    appearance.titleFont = [UIFont systemFontOfSize:18];
    appearance.messageFont = [UIFont systemFontOfSize:15];
    appearance.buttonFont = [UIFont systemFontOfSize:16];//[UIFont systemFontOfSize:[UIFont buttonFontSize]];
    appearance.cornerRadius = 6;
    appearance.shadowRadius = 6;
    appearance.transitionStyle = SIAlertViewTransitionStyleBounce;
}

- (id)init
{
	return [self initWithTitle:nil andMessage:nil];
}

- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message
{
    //Designated Initializer Norcy(20151110)
    return [self initWithTitle:title andMessage:message accesseryView:nil];
}

- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message accesseryView:(UIView *)accesseryView {
    return [self initWithTitle:title andMessage:message accesseryView:accesseryView accesseryViewStyle:SIAlertViewAccessaryViewStyleDefault];
}

// 选择图片的模式 alicejhchen (2016-04-21)
- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message accesseryView:(UIView *)accesseryView accesseryViewStyle:(SIAlertViewAccesseryViewStyle)style{
    if ( self = [super init] ) {
        _title = title;
        _message = message;
        self.items = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor clearColor];
        self.accesseryView = accesseryView;
        _messageTextAligment = NSTextAlignmentCenter;
        
        _accesseryViewStyle = style;
        self.textDistanceOfEdge = CONTENT_PADDING_LEFT;
    }
    
    return self;
}

- (id)initWithTxt:(NSString *)message
            title:(NSString *)title
      cancelTitle:(NSString *)cancelTitle
      cancelblock:(SIAlertViewButtonBlock)cancelblock
     confirmTitle:(NSString *)confirmTitle
     confirmblock:(SIAlertViewButtonBlock)confirmblock {
    if ( self = [super init] ) {
        _title = title;
        _message = message;
        _messageTextAligment = NSTextAlignmentCenter;
        
        self.items = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor clearColor];
        
        if ( cancelTitle.length ) {
            [self addButtonWithTitle:cancelTitle type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                if ( cancelblock ) {
                    cancelblock();
                }
            }];
        }
        
        if ( confirmTitle.length ) {
            [self addButtonWithTitle:confirmTitle type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                if ( confirmblock ) {
                    confirmblock();
                }
            }];
        }
        
        self.textDistanceOfEdge = CONTENT_PADDING_LEFT;
    }
    
    return self;
}

- (id)initWithTxt:(NSString *)message
       ImgBgTitle:(NSString *)title
      cancelTitle:(NSString *)cancelTitle
      cancelblock:(SIAlertViewButtonBlock)cancelblock
     confirmTitle:(NSString *)confirmTitle
     confirmblock:(SIAlertViewButtonBlock)confirmblock {
    if ( self = [super init] ) {
        _message = message;
        _messageTextAligment = NSTextAlignmentCenter;
        
        self.items = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor clearColor];
        
        if ( cancelTitle.length ) {
            [self addButtonWithTitle:cancelTitle type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                if ( cancelblock ) {
                    cancelblock();
                }
            }];
        }
        
        if ( confirmTitle.length ) {
            [self addButtonWithTitle:confirmTitle type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                if ( confirmblock ) {
                    confirmblock();
                }
            }];
        }
        
        if ( title.length ) {
            UIImageView * accessView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner_bg.png"]];
            [accessView sizeToFit];
            
            UIImageView * aFlag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner_flag.png"]];
            [aFlag sizeToFit];
            
            UILabel * aTitle = [[UILabel alloc] init];
            aTitle.font = [UIFont boldSystemFontOfSize:18];
            aTitle.textColor = [UIColor whiteColor];
            aTitle.text = title;
            [aTitle sizeToFit];
            
            aFlag.center = accessView.center;
            aTitle.center = accessView.center;
            
            [accessView addSubview:aFlag];
            [accessView addSubview:aTitle];
            
            self.accesseryView = accessView;
        }
        
        self.textDistanceOfEdge = CONTENT_PADDING_LEFT;
    }
    
    return self;
}

-(id)initWithImgBgName:(NSString *)name cancelTitle:(NSString *)cancelTitle cancelblock:(SIAlertViewButtonBlock)cancelblock confirmTitle:(NSString *)confirmTitle confirmblock:(SIAlertViewButtonBlock)confirmblock{
    if ( self = [super init] ) {
        self.items = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor clearColor];
        
        if ( cancelTitle.length ) {
            [self addButtonWithTitle:cancelTitle type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                if ( cancelblock ) {
                    cancelblock();
                }
            }];
        }
        
        if ( confirmTitle.length ) {
            [self addButtonWithTitle:confirmTitle type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                if ( confirmblock ) {
                    confirmblock();
                }
            }];
        }
        
        
        UIImageView * accessView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
        [accessView sizeToFit];
        self.accesseryView = accessView;
        self.textDistanceOfEdge = CONTENT_PADDING_LEFT;
    }
    
    return self;
}


- (id)initWithImg:(UIImage *)image
      cancelTitle:(NSString *)cancelTitle
      cancelblock:(SIAlertViewButtonBlock)cancelblock
     confirmTitle:(NSString *)confirmTitle
     confirmblock:(SIAlertViewButtonBlock)confirmblock
            style:(SIAlertViewBackgroundViewStyle)style {
    if ( self = [super init] ) {
        self.items = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor clearColor];
        self.backgroundViewStyle = style;
        
        if ( cancelTitle.length ) {
            [self addButtonWithTitle:cancelTitle type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                if ( cancelblock ) {
                    cancelblock();
                }
            }];
        }
        
        if ( confirmTitle.length ) {
            [self addButtonWithTitle:confirmTitle type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                if ( confirmblock ) {
                    confirmblock();
                }
            }];
        }
        
        
        UIImageView * accessView = [[UIImageView alloc] initWithImage:image];
        [accessView sizeToFit];
        self.accesseryView = accessView;
        self.textDistanceOfEdge = CONTENT_PADDING_LEFT;
        
    }
    
    return self;
}

+ (void)qlnoticeWithMsg:(NSString*)msg title:(NSString *)strTitle confirmTitle:(NSString *)confirmTitle cancelTitle:(NSString *)cancelTitle {
    if (![SIAlertView alreadyPopover]){
        SIAlertView *alert = [[SIAlertView alloc] initWithTxt:msg
                                                        title:strTitle
                                                  cancelTitle:cancelTitle
                                                  cancelblock:nil
                                                 confirmTitle:confirmTitle
                                                 confirmblock:nil];
        
        
        [alert show];
    }
}

// 4.9.0加的带对齐风格样式的弹框  elonliu
- (id)initWithTxt:(NSString *)message
            title:(NSString *)title
      cancelTitle:(NSString *)cancelTitle
      cancelblock:(SIAlertViewButtonBlock)cancelblock
     confirmTitle:(NSString *)confirmTitle
     confirmblock:(SIAlertViewButtonBlock)confirmblock
        textAligh:(NSTextAlignment)textAligh{
    if ( self = [super init] ) {
        _title = title;
        _message = message;
        _messageTextAligment = textAligh;
        
        self.items = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor clearColor];
        
        if ( cancelTitle.length ) {
            [self addButtonWithTitle:cancelTitle type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                if ( cancelblock ) {
                    cancelblock();
                }
            }];
        }
        
        if ( confirmTitle.length ) {
            [self addButtonWithTitle:confirmTitle type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                if ( confirmblock ) {
                    confirmblock();
                }
            }];
        }
        self.textDistanceOfEdge = CONTENT_PADDING_LEFT;
    }
    
    return self;
}

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
         confirmblock:(SIAlertViewButtonBlock)confirmblock {
    self = [super init];
    if (self) {
        _title = title;
        _message = nil;
        _messageTextAligment = NSTextAlignmentCenter;
        
        _attributedMessage = message;
        _linkURL = linkURL;
        _linkColor = linkColor;
        _activeColor = activeColor;
        _linkRange = linkRange;
        _linkBlock = linkBlock;
        
        self.items = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor clearColor];
        
        if ( cancelTitle.length ) {
            [self addButtonWithTitle:cancelTitle type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                if ( cancelblock ) {
                    cancelblock();
                }
            }];
        }
        
        if ( confirmTitle.length ) {
            [self addButtonWithTitle:confirmTitle type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                if ( confirmblock ) {
                    confirmblock();
                }
            }];
        }
        self.textDistanceOfEdge = CONTENT_PADDING_LEFT;
    }
    return self;
}

#pragma mark - Class methods

+ (NSMutableArray *)sharedQueue
{
    if (!__si_alert_queue) {
        __si_alert_queue = [NSMutableArray array];
    }
    return __si_alert_queue;
}

+ (SIAlertView *)currentAlertView
{
    return __si_alert_current_view;
}

+ (void)setCurrentAlertView:(SIAlertView *)alertView
{
    __si_alert_current_view = alertView;
}

+ (BOOL)isAnimating
{
    return __si_alert_animating;
}

+ (void)setAnimating:(BOOL)animating
{
    __si_alert_animating = animating;
}

+ (void)showBackground
{
    if (!__si_alert_background_window) {
        __si_alert_background_window = [[SIAlertBackgroundWindow alloc] initWithFrame:[UIScreen mainScreen].bounds
                                                                             andStyle:[SIAlertView currentAlertView].backgroundStyle];
        [__si_alert_background_window makeKeyAndVisible];
        __si_alert_background_window.alpha = 0;
        [UIView animateWithDuration:0.3
                         animations:^{
                             __si_alert_background_window.alpha = 1;
                         }];
    }
}

+ (void)hideBackgroundAnimated:(BOOL)animated
{
    if (!animated) {
        [__si_alert_background_window removeFromSuperview];
        __si_alert_background_window = nil;
        return;
    }
    [UIView animateWithDuration:0.3
                     animations:^{
                         __si_alert_background_window.alpha = 0;
                     }
                     completion:^(BOOL finished) {
//                         QLLogS(@"UIView animation completion");
                         [__si_alert_background_window removeFromSuperview];
                         __si_alert_background_window = nil;
                     }];
}

- (void)setOrientationMode:(NSInteger)aMode {
    SIAlertViewController * sViewCtl = (SIAlertViewController *)self.alertWindow.rootViewController;
    
    if ( [sViewCtl isKindOfClass:[SIAlertViewController class]] ) {
        sViewCtl.orientationMode = aMode;
    }
}

#pragma mark - Setters

- (void)setTitle:(NSString *)title
{
    _title = title;
	[self invaliadateLayout];
}

- (void)setMessage:(NSString *)message
{
	_message = message;
    [self invaliadateLayout];
}

#pragma mark - Getter

- (UIColor *)linkColor {
    if (!_linkColor) {
        _linkColor = RGBCOLOR(0xff, 0x70, 0x00);
    }
    return _linkColor;
}

- (UIColor *)activeColor {
    if (!_activeColor) {
        _activeColor = [UIColor orangeColor];
    }
    return _activeColor;
}

#pragma mark - Public

- (void)addButtonWithTitle:(NSString *)title type:(SIAlertViewButtonType)type handler:(SIAlertViewHandler)handler
{
    SIAlertItem *item = [[SIAlertItem alloc] init];
	item.title = title;
	item.type = type;
	item.action = handler;
	[self.items addObject:item];
}

- (void)addButtonWithTitle:(NSString *)title image:(UIImage *)image type:(SIAlertViewButtonType)type customHandler:(SIAlertViewBtnHandler)handler
{
    SIAlertItem *item = [[SIAlertItem alloc] init];
    item.title = title;
    item.type = type;
    item.customAction = handler;
    item.btnImage = image;
    [self.items addObject:item];
}

- (void)show
{
    // show 之前关闭已有的 alertview
//    SIAlertView * curAlert = [[self class] currentAlertView];
//    if ( curAlert ) {
//        [curAlert dismissAnimated:NO];
//    }
    
    if (![[SIAlertView sharedQueue] containsObject:self]) {
        [[SIAlertView sharedQueue] addObject:self];
    }
    
    if ([SIAlertView isAnimating]) {
        return; // wait for next turn
    }
    
    if (self.isVisible) {
        return;
    }
    
    if ([SIAlertView currentAlertView].isVisible) {
        SIAlertView *alert = [SIAlertView currentAlertView];
        [alert dismissAnimated:YES cleanup:NO];
        return;
    }
    
    if (self.willShowHandler) {
        self.willShowHandler(self);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SIAlertViewWillShowNotification object:self userInfo:nil];
    
    self.visible = YES;
    self.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    
    [SIAlertView setAnimating:YES];
    [SIAlertView setCurrentAlertView:self];
    
    // transition background
    //[SIAlertView showBackground];
    
    SIAlertViewController *viewController = [[SIAlertViewController alloc] initWithNibName:nil bundle:nil];
    viewController.alertView = self;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ( UIInterfaceOrientationPortrait != orientation ) {
        viewController.orientationMode = 1;
    } else {
        // transition background
        [SIAlertView showBackground];
    }

    
    if (!self.alertWindow) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = UIWindowLevelSIAlert;
        window.rootViewController = viewController;
        self.alertWindow = window;
    }
    
    if (_supportClickBGViewDismiss) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBGViewDismiss)];
        tapGesture.delegate = self;
        [self.alertWindow addGestureRecognizer:tapGesture];
    }
    
    [self.alertWindow makeKeyAndVisible];
    
    [self validateLayout];
    
    [self transitionInCompletion:^{
//        QLLogS(@"UIView animation completion");
        if (self.didShowHandler) {
            self.didShowHandler(self);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:SIAlertViewDidShowNotification object:self userInfo:nil];
        
        [SIAlertView setAnimating:NO];
        
        NSInteger index = [[SIAlertView sharedQueue] indexOfObject:self];
        if (index < [SIAlertView sharedQueue].count - 1) {
            [self dismissAnimated:YES cleanup:NO]; // dismiss to show next alert view
        }
    }];

//    ColorSubviews(self.containerView);
}

- (void)clickBGViewDismiss
{
    [SIAlertView dismissAlertView];    
}

+ (BOOL)alreadyPopover {
    UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
    
    if ( keyWindow && keyWindow.windowLevel == UIWindowLevelSIAlert ) {
        return YES;
    }
    
    return NO;
}

+ (void)dismissAlertView {
    SIAlertView * curAlertView = [self currentAlertView];
    
    if ( curAlertView ) {
        [curAlertView dismissAnimated:NO];
    }
}

- (void)dismissAnimated:(BOOL)animated
{
    [self dismissAnimated:animated cleanup:YES];
}

- (void)dismissAnimated:(BOOL)animated cleanup:(BOOL)cleanup
{
    BOOL isVisible = self.isVisible;
    
    if (isVisible) {
        if (self.willDismissHandler) {
            self.willDismissHandler(self);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:SIAlertViewWillDismissNotification object:self userInfo:nil];
    }
    
    void (^dismissComplete)(void) = ^{
        @autoreleasepool {
            self.visible = NO;
            
            [self teardown];
            
            [SIAlertView setCurrentAlertView:nil];
            
            SIAlertView *nextAlertView;
            NSInteger index = [[SIAlertView sharedQueue] indexOfObject:self];
            if (index != NSNotFound && index < [SIAlertView sharedQueue].count - 1) {
                nextAlertView = [SIAlertView sharedQueue][index + 1];
            }
            
            if (cleanup) {
                [[SIAlertView sharedQueue] removeObject:self];
            }
            
            [SIAlertView setAnimating:NO];
            
            if (isVisible) {
                if (self.didDismissHandler) {
                    self.didDismissHandler(self);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:SIAlertViewDidDismissNotification object:self userInfo:nil];
            }
            
            // check if we should show next alert
            if (!isVisible) {
                return;
            }
            
            if (nextAlertView) {
                [nextAlertView show];
            } else {
                // show last alert view
                if ([SIAlertView sharedQueue].count > 0) {
                    SIAlertView *alert = [[SIAlertView sharedQueue] lastObject];
                    [alert show];
                }
            }
        }
    };
    
    if (animated && isVisible) {
        [SIAlertView setAnimating:YES];
        [self transitionOutCompletion:dismissComplete];
        
        if ([SIAlertView sharedQueue].count == 1) {
            [SIAlertView hideBackgroundAnimated:YES];
        }
        
    } else {
        dismissComplete();
        
        if ([SIAlertView sharedQueue].count == 0) {
            [SIAlertView hideBackgroundAnimated:YES];
        }
    }
}

#pragma mark - Transitions

- (void)transitionInCompletion:(void(^)(void))completion
{
    switch (self.transitionStyle) {
        case SIAlertViewTransitionStyleSlideFromBottom:
        {
            CGRect rect = self.containerView.frame;
            CGRect originalRect = rect;
            rect.origin.y = self.bounds.size.height;
            self.containerView.frame = rect;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.containerView.frame = originalRect;
                             }
                             completion:^(BOOL finished) {
//                                 QLLogS(@"UIView animation completion");
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case SIAlertViewTransitionStyleSlideFromTop:
        {
            CGRect rect = self.containerView.frame;
            CGRect originalRect = rect;
            rect.origin.y = -rect.size.height;
            self.containerView.frame = rect;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.containerView.frame = originalRect;
                             }
                             completion:^(BOOL finished) {
//                                 QLLogS(@"UIView animation completion");
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case SIAlertViewTransitionStyleFade:
        {
            self.containerView.alpha = 0;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.containerView.alpha = 1;
                             }
                             completion:^(BOOL finished) {
//                                 QLLogS(@"UIView animation completion");
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case SIAlertViewTransitionStyleBounce:
        {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
//            animation.values = @[@(1.01), @(1.1), @(0.9), @(1)];
//            animation.keyTimes = @[@(0), @(0.4), @(0.6), @(1)];
            
//            animation.values = @[@(0.9), @(1), @(0.9), @(1)];
//            animation.keyTimes = @[@(0), @(0.4), @(0.6), @(1)];

            animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],
                                 [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1)],
                                 [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)]];
            animation.keyTimes = @[ @0, @0.5, @1 ];
            
//            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.fillMode = kCAFillModeForwards;
            animation.removedOnCompletion = YES;
            animation.duration = 0.3;
            animation.delegate = self;
            [animation setValue:completion forKey:@"handler"];
            [self.containerView.layer addAnimation:animation forKey:@"bouce"];
        }
            break;
        case SIAlertViewTransitionStyleDropDown:
        {
            CGFloat y = self.containerView.center.y;
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
            animation.values = @[@(y - self.bounds.size.height), @(y + 20), @(y - 10), @(y)];
            animation.keyTimes = @[@(0), @(0.5), @(0.75), @(1)];
            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.duration = 0.4;
            animation.delegate = self;
            [animation setValue:completion forKey:@"handler"];
            [self.containerView.layer addAnimation:animation forKey:@"dropdown"];
        }
            break;
        default:
            break;
    }
}

- (void)transitionOutCompletion:(void(^)(void))completion
{
    switch (self.transitionStyle) {
        case SIAlertViewTransitionStyleSlideFromBottom:
        {
            CGRect rect = self.containerView.frame;
            rect.origin.y = self.bounds.size.height;
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.containerView.frame = rect;
                             }
                             completion:^(BOOL finished) {
//                                 QLLogS(@"UIView animation completion");
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case SIAlertViewTransitionStyleSlideFromTop:
        {
            CGRect rect = self.containerView.frame;
            rect.origin.y = -rect.size.height;
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.containerView.frame = rect;
                             }
                             completion:^(BOOL finished) {
//                                 QLLogS(@"UIView animation completion");
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case SIAlertViewTransitionStyleBounce:
        case SIAlertViewTransitionStyleFade:
        {
            [UIView animateWithDuration:0.25
                             animations:^{
                                 self.containerView.alpha = 0;
                             }
                             completion:^(BOOL finished) {
//                                 QLLogS(@"UIView animation completion");
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
//        case SIAlertViewTransitionStyleBounce:
//        {
//            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
//            animation.values = @[@(1), @(1.2), @(0.01)];
//            animation.keyTimes = @[@(0), @(0.4), @(1)];
//            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
//            animation.duration = 0.35;
//            animation.delegate = self;
//            [animation setValue:completion forKey:@"handler"];
//            [self.containerView.layer addAnimation:animation forKey:@"bounce"];
//            
//            self.containerView.transform = CGAffineTransformMakeScale(0.01, 0.01);
//        }
//            break;
        case SIAlertViewTransitionStyleDropDown:
        {
            CGPoint point = self.containerView.center;
            point.y += self.bounds.size.height;
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.containerView.center = point;
                                 CGFloat angle = ((CGFloat)arc4random_uniform(100) - 50.f) / 100.f;
                                 self.containerView.transform = CGAffineTransformMakeRotation(angle);
                             }
                             completion:^(BOOL finished) {
//                                 QLLogS(@"UIView animation completion");
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        default:
            break;
    }
}

- (void)resetTransition
{
    [self.containerView.layer removeAllAnimations];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self validateLayout];
}

- (void)invaliadateLayout
{
    self.layoutDirty = YES;
    [self setNeedsLayout];
}

- (UIView *)lineWithWidth:(CGFloat)width height:(CGFloat)height {
    UIView * viewRet = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    viewRet.backgroundColor = [UIColor lightGrayColor];
    return viewRet;
}

- (void)validateLayout
{
    if (!self.isLayoutDirty) {
        return;
    }
    self.layoutDirty = NO;
#if DEBUG_LAYOUT
    NSLog(@"%@, %@", self, NSStringFromSelector(_cmd));
#endif
    
    CGFloat height = [self preferredHeight];
    CGFloat left = ceilf((self.bounds.size.width - CONTAINER_WIDTH) * 0.5);
    CGFloat top = ceilf((self.bounds.size.height - height) * 0.5);
    self.containerView.transform = CGAffineTransformIdentity;
    self.containerView.frame = CGRectMake(left, top, CONTAINER_WIDTH, height);
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds cornerRadius:self.containerView.layer.cornerRadius].CGPath;
    self.containerView.clipsToBounds = YES;
    CGFloat maxLabelWidth = self.containerView.bounds.size.width - self.textDistanceOfEdge * 2;
    CGFloat titleHeight = 0, messageHeight = 0;
    
    CGFloat y = 0;
    CGFloat textX = 0;
    
    if (self.accesseryView)
    {
        //这里需要做适配，防止view的拉伸或者压扁  zhangliao (2015/12/02)
        [self accesseryViewAdaptiveAdjust];
        
        // 左图右文模式记录文本originX alicejhchen (2016-04-21)
        if (_accesseryViewStyle == SIAlertViewAccessaryViewStyleLeft) {
            
            self.accesseryView.frame = CGRectMake(10, y, self.accesseryView.frame.size.width, self.accesseryView.frame.size.height);
            
            textX += (self.accesseryView.frame.origin.x + self.accesseryView.frame.size.width);
            maxLabelWidth -= (self.accesseryView.frame.origin.x + self.accesseryView.frame.size.width);
        } else {
            CGRect frame = self.accesseryView.frame;
            frame.origin = CGPointMake((self.containerView.frame.size.width - self.accesseryView.frame.size.width)/2.0, y);;
            self.accesseryView.frame = frame;
            y += self.accesseryView.frame.size.height;
        }
    }
    
	if (self.titleLabel)
    {
        y += TITLE_PADDING_TOP;
        self.titleLabel.text = self.title;
        titleHeight = [self heightForTitleLabel];
        
        self.titleLabel.frame = CGRectMake(textX + self.textDistanceOfEdge, y, maxLabelWidth, titleHeight);
        y += titleHeight;
	}
    
    // 添加了 attributeLabel 的选项 (Add by Mark)
    if (self.messageLabel || self.attributedLabel)
    {
        if (self.titleLabel)
            y += GAP;
        else
            y += TITLE_PADDING_TOP;
        if (self.messageLabel) {
            self.messageLabel.text = self.message;
        }
        if (self.attributedLabel) {
            [self setAttributedTextForAttributedLabel];
        }
        
        messageHeight = [self heightForMessageLabel];
        
        if (self.messageLabel) {
            self.messageLabel.frame = CGRectMake(textX + self.textDistanceOfEdge, y, maxLabelWidth, messageHeight);
        }
        if (self.attributedLabel) {
            self.attributedLabel.frame = CGRectMake(textX + self.textDistanceOfEdge, y, maxLabelWidth, messageHeight);
        }
        y += messageHeight;
    }
    
    //高度太小，没图的情况下需要重新调整布局 v4.5.2Norcy(2015双11)
    BOOL hasRelayout = NO;
    if (y < [self getMiniHeight] && (!self.accesseryView || self.accesseryViewStyle == SIAlertViewAccessaryViewStyleLeft))
    {
        hasRelayout = YES;
        CGFloat contentHeight = titleHeight+messageHeight;
        if (self.titleLabel && self.messageLabel)
            contentHeight += GAP;
        CGFloat newY = ceilf(([self getMiniHeight]-contentHeight)/2);
        if (self.titleLabel)
        {
            newY = [self getTitleTop:newY];
            self.titleLabel.top = newY;
            newY += titleHeight;
        }
        if (self.messageLabel || self.attributedLabel)
        {
            if (self.titleLabel) { newY += GAP; }
            if (self.messageLabel) {
                newY = [self getMessageTop:newY];
                self.messageLabel.top = newY;
            }
            if (self.attributedLabel) {
                self.attributedLabel.top = newY;
            }
            newY += messageHeight;
        }
        
        y = [self getMiniHeight];
    }
    
    // 重新调整accesseryView的位置,使其在文字区域上下居中   alicejhchen (2016-04-21)
    if (self.accesseryView && self.accesseryViewStyle == SIAlertViewAccessaryViewStyleLeft) {
        self.accesseryView.origin = CGPointMake(self.accesseryView.left, (y - self.accesseryView.height)/2);
    }
    
     y = [self yOflayoutCustomViewFromY:y];
    
    if (self.items.count > 0)
    {
        //上图下文style下 只有一张背景图的情况 高度根据图的高度设置  ericlezhou 2016-05-11
        BOOL onlyPicBG = NO;
        if (!self.title.length && !self.message.length && !self.attributedMessage.length && self.accesseryViewStyle == SIAlertViewAccessaryViewStyleDefault && self.accesseryView) {
            onlyPicBG = YES;
        }
        if (!hasRelayout){
            if (!onlyPicBG) {
                y += CONTENT_BUTTONS_GAP;
            }
        }
        
        // 添加线条
        CGFloat buttonGap = 0;//CONTENT_PADDING_LEFT; - GAP + GAP
        
        if (self.items.count == 2) {
            CGFloat width = ceilf((self.containerView.bounds.size.width - buttonGap * 2 ) * 0.5);
            UIButton *button = self.buttons[0];
            button.frame = CGRectMake(buttonGap, y, width, BUTTON_HEIGHT);

            UIView *topLine = self.lines[0];
            topLine.frame = CGRectMake([self getHorizontalLinePadding], button.frame.origin.y, self.containerView.bounds.size.width - 2*[self getHorizontalLinePadding], 0.5);
            
            UIView *colLine = self.lines[1];
            colLine.frame = CGRectMake(self.containerView.frame.size.width / 2.0, button.frame.origin.y + 1 + [self getVerticalLinePadding], 0.5, button.frame.size.height - 1 - 2 *[self getVerticalLinePadding]);

            button = self.buttons[1];
            button.frame = CGRectMake(buttonGap + width , y, width, BUTTON_HEIGHT);
        } else {
            for (NSUInteger i = 0; i < self.buttons.count; i++) {
                UIButton *button = self.buttons[i];
                button.frame = CGRectMake(buttonGap, ceilf(y), ceilf(self.containerView.bounds.size.width - buttonGap * 2), BUTTON_HEIGHT);
                
#ifdef DEBUG
//                if ( i == 0 ) {
//                    button.backgroundColor = [UIColor redColor];
//                }
#endif
                
                UIView *topLine = self.lines[i];
                topLine.frame = CGRectMake(0, ceilf(button.frame.origin.y), self.containerView.bounds.size.width, .5);

                if (self.buttons.count > 1) {
                    if (i == self.buttons.count - 1 && ((SIAlertItem *)self.items[i]).type == SIAlertViewButtonTypeCancel) {
                        CGRect rect = button.frame;
                        rect.origin.y += CANCEL_BUTTON_PADDING_TOP;
                        button.frame = rect;
                    }
                    y += BUTTON_HEIGHT ;//+ GAP
                }
            }
        }
        
        if (onlyPicBG) {
            //单背景的情况，按钮显示白色，第一条横向分割线不显示
            for (int i = 0; i < self.items.count; i++) {
                [self.buttons[i] setBackgroundColor:[UIColor whiteColor]];
            }
            UIView *topline = self.lines[0];
            if (topline.superview) {
                topline.hidden = YES;
                if (self.items.count == 2) {
                    UIButton *button = self.buttons[0];
                    UIView *colLine = self.lines[1];
                    colLine.frame = CGRectMake(self.containerView.frame.size.width / 2.0, button.frame.origin.y, 0.5, button.frame.size.height);
                }
            }
            
        }
    }
}

- (CGFloat)getTitleTop:(CGFloat)top
{
    return top;
}

- (CGFloat)getMessageTop:(CGFloat)top
{
    return top;
}

- (CGFloat)getMiniHeight
{
    return CONTENT_MIN_HEIGHT;
}

-(CGFloat)getHorizontalLinePadding
{
    return 0;
}

-(CGFloat)getVerticalLinePadding
{
    return 0;
}

- (void)setAttributedTextForAttributedLabel
{
    // 没必要在Block里创建一个新的AttributedString，所有的属性在创建的时候设置好即可，否则极易导致部分属性丢失
	[self.attributedLabel setText:self.attributedMessage afterInheritingLabelAttributesAndConfiguringWithBlock:nil];
	[self.attributedLabel addLinkToURL:self.linkURL withRange:self.linkRange];
}

- (CGFloat)preferredHeight
{
	CGFloat height = 0;
    CGFloat accesseryHeight = 0;
    
    BOOL onlyPicBG = NO; //上图下文情况下 只有一张背景图的情况 高度根据图的高度设置，并且适配现有的弹框宽度  ericlezhou 2016-05-11
    if (!self.title.length && !self.message.length && !self.attributedMessage.length && self.accesseryViewStyle == SIAlertViewAccessaryViewStyleDefault && self.accesseryView) {
        onlyPicBG = YES;
    }
    
    if (self.accesseryView){
        if (onlyPicBG) {
            CGFloat tempH = self.accesseryView.height;
            CGFloat tempW = self.accesseryView.width;
            if (self.accesseryView.width < CONTAINER_WIDTH && self.accesseryView.width > CONTAINER_WIDTH * 0.1) {
                tempW = CONTAINER_WIDTH;
                tempH = tempW * (self.accesseryView.height / self.accesseryView.width);
                self.accesseryView.size = CGSizeMake(tempW, tempH);
            }else {
                //这里需要做适配，要不然会出现accesseryView的高度小于containerView的高度，渲染后弹窗底部会有空白 add in V5.3 georgema  20161128
                [self accesseryViewAdaptiveAdjust];
            }
        }else{
            //这里需要做适配，防止view的拉伸或者压扁  zhangliao (2015/12/02)
            [self accesseryViewAdaptiveAdjust];
        }
        // 左图右文模式记录图片的高度，方便内容区域取图片和文本的最大高度 alicejhchen (2016-04-21)
        if (_accesseryViewStyle == SIAlertViewAccessaryViewStyleLeft) {
            accesseryHeight = self.accesseryView.height;
        } else {
            height += self.accesseryView.height;
        }
    }
    
	if (self.title.length)
    {
        height += TITLE_PADDING_TOP;
		height += [self heightForTitleLabel];
	}
    
    if (self.message.length || self.attributedMessage.length)
    {
        if (self.title.length)
            height += GAP;
        else
            height += TITLE_PADDING_TOP;
        
        height += [self heightForMessageLabel];
    }
    
    // 左图右文模式取图片和文本的最大高度 alicejhchen (2016-04-21)
    height = MAX(accesseryHeight, height);

    //高度太小，没图或图片不是左图右文的情况下需要重新调整布局 v4.5.2Norcy(2015双11)
    BOOL hasRelayout = NO;
    if (height < [self getMiniHeight] && (!self.accesseryView || self.accesseryViewStyle == SIAlertViewAccessaryViewStyleLeft))
    {
        hasRelayout = YES;
        height = [self getMiniHeight];
    }
    if (self.items.count > 0)
    {
        if (!hasRelayout){
            if (!onlyPicBG){
                height += CONTENT_BUTTONS_GAP;
            }
        }
        if (self.items.count <= 2)
            height += BUTTON_HEIGHT;
        else
            height += (BUTTON_HEIGHT ) * self.items.count;
    }
    height += [self heightForOtherView];
    if ([self resetYOffset]) {
        height -= [self resetYOffset];        
    }
	return ceilf(height);
}

- (CGFloat)heightForTitleLabel
{
    if (self.titleLabel) {
//        CGSize size = [self.title ql_sizeWithFont:self.titleLabel.font
//                                   minFontSize:
//#ifndef __IPHONE_6_0
//                       self.titleLabel.font.pointSize * self.titleLabel.minimumScaleFactor
//#else
//                       self.titleLabel.minimumFontSize
//#endif
//                                actualFontSize:nil
//                                      forWidth:CONTAINER_WIDTH - CONTENT_PADDING_LEFT * 2
//                                 lineBreakMode:self.titleLabel.lineBreakMode];
//        return ceilf(size.height);
        
        // 左图右文模式文本的最大宽度需要减去图片的宽度 alicejhchen (2016-04-21)
        CGFloat maxWidth = CONTAINER_WIDTH - CONTENT_PADDING_LEFT * 2;
        if (self.accesseryView && _accesseryViewStyle == SIAlertViewAccessaryViewStyleLeft)
        {
            maxWidth -= self.accesseryView.right;
        }
        
        CGFloat maxHeight = MESSAGE_MAX_LINE_COUNT * self.titleLabel.font.lineHeight;
//        CGSize size = [self.title ql_sizeWithFont:self.titleLabel.font
//                             constrainedToSize:CGSizeMake(maxWidth, maxHeight)
//                                 lineBreakMode:NSLineBreakByWordWrapping
//                                     needCache:NO];
        //使用QLHTMLFontLabel必须使用autoCaculateAttributedTextSize来计算文字高度，在QLHTMLFontLabel头文件中有说明
        CGSize size = [self.titleLabel autoCaculateAttributedTextSize:CGSizeMake(maxWidth, maxHeight)];
        return ceilf(size.height);

    }
    return 0;
}

// 该方法添加了对 attributedLabel 的支持，attributedLabel 和 messageLabel 只能存在一种
- (CGFloat)heightForMessageLabel
{
    if ( !self.messageLabel.text.length && ![self.attributedLabel.text length] ) {
        return 4;
    }
    
    // 左图右文模式文本的最大宽度需要减去图片的宽度 alicejhchen (2016-04-21)
    CGFloat maxWidth = CONTAINER_WIDTH - CONTENT_PADDING_LEFT * 2;
    if (self.accesseryView && _accesseryViewStyle == SIAlertViewAccessaryViewStyleLeft)
    {
        maxWidth -= self.accesseryView.right;
    }
    
    CGFloat minHeight = MESSAGE_MIN_LINE_COUNT * self.messageFont.lineHeight;
    // AttributeLabel 逻辑 (Add by Mark 2016/08/15)
    if (self.messageLabel || self.attributedLabel) {
        CGSize size = CGSizeZero;
        if (self.message) {
//            size = [[self.message stringByRemovingHTMLTags] ql_sizeWithFont:self.messageLabel.font
//                                                             constrainedToSize:CGSizeMake(maxWidth, maxHeight)
//                                                                 lineBreakMode:NSLineBreakByWordWrapping];
            size.height = [self.messageLabel heightWithMaxWidth:maxWidth lineSpacing:LINE_SPACE maxLine:MESSAGE_MAX_LINE_COUNT];
//            size.height = [UILabel heightWithLineSpace:LINE_SPACE text:self.messageLabel.text maxWidth:maxWidth lines:MESSAGE_MAX_LINE_COUNT font:self.messageLabel.font];
//            NSAttributedString *attrStr = self.messageLabel.attributedText;// your attributed string
//            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(maxWidth, maxHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
//            size = rect.size;
        }
        
        if (self.attributedMessage) {
//            CGFloat maxHeight = MESSAGE_MAX_LINE_COUNT * self.messageFont.lineHeight;
//            size = [self.attributedMessage boundingRectWithSize:CGSizeMake(maxWidth, maxHeight)
//                                                        options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
//                                                     attributes:@{NSFontAttributeName: [SIAlertView appearance].messageFont}
//                                                        context:nil].size;
//            size.height = [UILabel heightWithLineSpace:LINE_SPACE text:self.attributedLabel.text maxWidth:maxWidth lines:MESSAGE_MAX_LINE_COUNT font:[SIAlertView appearance].messageFont];
            size.height = [self.attributedLabel getAttributedStringHeightWidthValue:maxWidth];
        }
        
        if ( size.height > minHeight ) {
            return ceilf(size.height) + 1;//10;
        }
        
        return ceilf(minHeight);//ceilf(MAX(minHeight, size.height)) + 10;
    }
   
    return ceilf(minHeight);
}

#pragma mark - Setup

- (void)setup
{
    [self setupContainerView];
    [self setupAccesseryView];
    [self updateTitleLabel];
    [self updateMessageLabel];
    [self updateOtherViewsSuperView:self.containerView];
    [self setupButtons];
    [self setupLines];
    [self invaliadateLayout];
}

- (void)teardown
{
    [self.containerView removeFromSuperview];
    self.containerView = nil;
    self.titleLabel = nil;
    self.messageLabel = nil;
    self.attributedLabel = nil;
    [self.buttons removeAllObjects];
    [self.alertWindow removeFromSuperview];
    self.alertWindow.rootViewController = nil;
    self.alertWindow = nil;
    [self resetOtherViews];
    [self removeFromSuperview];
}

+ (UIView *)blurViewWithFrame:(CGRect)frame backgroundViewStyle:(SIAlertViewBackgroundViewStyle)style {
    UIView * viewRet = nil;
    if (style == SIAlertViewBackgroundViewStyleTranslucent) {
        viewRet = [[UIImageView alloc] initWithFrame:frame];
        viewRet.backgroundColor = [UIColor clearColor];
        viewRet.userInteractionEnabled = YES;
    }else if ([UIDevice isIOS7OrLatter]) {
        viewRet = [[UIToolbar alloc] initWithFrame:frame];
    } else {
        viewRet = [[UIImageView alloc] initWithFrame:frame];
        viewRet.backgroundColor = [UIColor whiteColor];
        viewRet.userInteractionEnabled = YES;
    }
    return viewRet;
}

- (void)setupContainerView
{
    self.containerView = [SIAlertView blurViewWithFrame:self.bounds backgroundViewStyle:self.backgroundViewStyle];//[[UIView alloc] initWithFrame:self.bounds];
//    self.containerView.backgroundColor = [UIColor whiteColor];
    
//    self.containerView.layer.cornerRadius = self.cornerRadius;
//    self.containerView.layer.shadowOffset = CGSizeZero;
//    self.containerView.layer.shadowRadius = self.shadowRadius;
//    self.containerView.layer.shadowOpacity = 0.5;
    
    [self addSubview:self.containerView];
}

- (void)setupAccesseryView {
    if ( self.accesseryView ) {
        [self.containerView addSubview:self.accesseryView];
    }
}

- (void)updateTitleLabel
{
	if (self.title.length) {
		if (!self.titleLabel) {
			self.titleLabel = [[QLHTMLFontLabel alloc] initWithFrame:self.bounds];
			self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.backgroundColor = [UIColor clearColor];
			self.titleLabel.font = self.titleFont;
            self.titleLabel.textColor = self.titleColor;
//            self.titleLabel.adjustsFontSizeToFitWidth = YES;
//#ifndef __IPHONE_6_0
//            self.titleLabel.minimumScaleFactor = 0.75;
//#else
//            self.titleLabel.minimumFontSize = self.titleLabel.font.pointSize * 0.75;
//#endif
            self.titleLabel.numberOfLines = 0;
			[self.containerView addSubview:self.titleLabel];
#if DEBUG_LAYOUT
            self.titleLabel.backgroundColor = [UIColor redColor];
#endif
		}
		self.titleLabel.text = self.title;
	} else {
		[self.titleLabel removeFromSuperview];
		self.titleLabel = nil;
	}
    [self invaliadateLayout];
}

- (void)updateMessageLabel
{
    [self setupMessageLabel];
   
    // 带链接的弹窗 (Add by Mark 2016/08/15)
    [self setupAttributedLabel];
    
    [self invaliadateLayout];
}

- (void)setupMessageLabel {
    if (self.message.length) {
        if (!self.messageLabel) {
#ifdef MESSAGE_USE_LABLE
            self.messageLabel = [[QLHTMLFontLabel alloc] initWithFrame:self.bounds];
            self.messageLabel.numberOfLines = MESSAGE_MAX_LINE_COUNT;
#else
            self.messageLabel = [[QLHTMLFontTextView alloc] initWithFrame:self.bounds];
            self.messageLabel.editable = NO;
            self.messageLabel.selectable = NO;
            self.messageLabel.textContainerInset = UIEdgeInsetsZero;
            self.messageLabel.contentInset = UIEdgeInsetsZero;

            //fix ios7 crash by deron
            //self.messageLabel.layoutMargins = UIEdgeInsetsZero;
            
            self.messageLabel.textContainer.lineFragmentPadding = 0;
            //            self.messageLabel.layoutManager.allowsNonContiguousLayout = NO;
#endif
            self.messageLabel.backgroundColor = [UIColor clearColor];
            self.messageLabel.font = [SIAlertView appearance].messageFont;
            self.messageLabel.textColor = self.messageColor;
            
            [self.containerView addSubview:self.messageLabel];
#ifdef DEBUG
            //            self.messageLabel.backgroundColor = [UIColor redColor];
#endif
        }
//        self.messageLabel.text = self.message;
        [self.messageLabel setText:self.message lineSpacing:LINE_SPACE];
        self.messageLabel.textAlignment = self.messageTextAligment;//NSTextAlignmentCenter; //设置Text Space的时候会导致对齐方式改变，故重新设置回来
    } else {
        [self.messageLabel removeFromSuperview];
        self.messageLabel = nil;
    }
}

- (void)setupAttributedLabel {

    if (self.attributedMessage.length) {
        self.attributedLabel = [[QLAttributedLabel alloc] initWithFrame:CGRectZero];
        self.attributedLabel.numberOfLines = MESSAGE_MAX_LINE_COUNT;
        self.attributedLabel.verticalAlignment = QLAttributedLabelVerticalAlignmentCenter;
        self.attributedLabel.delegate = self;
        self.attributedLabel.font = [SIAlertView appearance].messageFont;
        self.attributedLabel.textColor = [SIAlertView appearance].messageColor;
        self.attributedLabel.leading = LINE_SPACE;
        self.attributedLabel.lineHeightMultiple = 1.f;
        self.attributedLabel.linkAttributes = [self linkAttributesWithColor:self.linkColor];
        self.attributedLabel.activeLinkAttributes = [self linkAttributesWithColor:self.activeColor];
        [self setAttributedTextForAttributedLabel];
        
        [self.containerView addSubview:self.attributedLabel];
    } else {
        [self.attributedLabel removeFromSuperview];
        self.attributedLabel = nil;
    }
    
}

- (NSDictionary *)linkAttributesWithColor:(UIColor *)linkColor {
    return @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
             NSUnderlineColorAttributeName: linkColor,
             NSForegroundColorAttributeName: linkColor};
}

- (void)setupButtons
{
    self.buttons = [[NSMutableArray alloc] initWithCapacity:self.items.count];
    for (NSUInteger i = 0; i < self.items.count; i++) {
        UIButton *button = [self buttonForItemIndex:i];
        [self.buttons addObject:button];
        [self.containerView addSubview:button];
    }
}

- (void)setupLines {
    self.lines = [[NSMutableArray alloc] initWithCapacity:self.items.count];
    for (NSUInteger i = 0; i < self.items.count; i++) {
        UIView *line = [self lineWithWidth:100 height:0.5];
        [self.lines addObject:line];
        [self.containerView addSubview:line];
    }
}

- (UIButton *)buttonForItemIndex:(NSUInteger)index
{
    SIAlertItem *item = self.items[index];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.tag = index;
	button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    button.titleLabel.font = self.buttonFont;
	[button setTitle:item.title forState:UIControlStateNormal];
//	UIImage *normalImage = nil;
//	UIImage *highlightedImage = nil;
	switch (item.type) {
		case SIAlertViewButtonTypeCancel:
//			normalImage = [UIImage imageNamed:@"SIAlertView.bundle/button-cancel"];
//			highlightedImage = [UIImage imageNamed:@"SIAlertView.bundle/button-cancel-d"];
			[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateHighlighted];
			break;
		case SIAlertViewButtonTypeDestructive:
//			normalImage = [UIImage imageNamed:@"SIAlertView.bundle/button-destructive"];
//			highlightedImage = [UIImage imageNamed:@"SIAlertView.bundle/button-destructive-d"];
            [button setTitleColor:RGBCOLOR(0x22, 0x22, 0x22) forState:UIControlStateNormal];
//            [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateHighlighted];
			break;
		case SIAlertViewButtonTypeDefault:
		default:
//			normalImage = [UIImage imageNamed:@"SIAlertView.bundle/button-default"];
//			highlightedImage = [UIImage imageNamed:@"SIAlertView.bundle/button-default-d"];
			[button setTitleColor:RGBCOLOR(0xff, 0x70, 0x00) forState:UIControlStateNormal];
//            [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateHighlighted];
			break;
	}
    if(item.btnImage){
        [button setImage:item.btnImage forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    }
//	CGFloat hInset = floorf(normalImage.size.width / 2);
//	CGFloat vInset = floorf(normalImage.size.height / 2);
//	UIEdgeInsets insets = UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
//	normalImage = [normalImage resizableImageWithCapInsets:insets];
//	highlightedImage = [highlightedImage resizableImageWithCapInsets:insets];
//	[button setBackgroundImage:normalImage forState:UIControlStateNormal];
//	[button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(buttonTouchCancel:) forControlEvents:UIControlEventTouchDragExit];

    return button;
}

#pragma mark - Actions

- (void)buttonWasPressed:(UIButton *)button
{
	[SIAlertView setAnimating:YES]; // set this flag to YES in order to prevent showing another alert in action block
    SIAlertItem *item = self.items[button.tag];
    BOOL shouldDismiss = YES;
    if (item.customAction) {
       shouldDismiss = item.customAction(self,button);
    }
	else if (item.action) {
		item.action(self);
	}
    if (shouldDismiss) {
        [self dismissAnimated:YES];
        
        [button setBackgroundColor:[UIColor clearColor]];
    }

}

- (void)buttonTouchDown:(UIButton *)button {
    [button setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:0.9]];
}

- (void)buttonTouchCancel:(UIButton *)button {
    if (self.backgroundViewStyle == SIAlertViewBackgroundViewStyleTranslucent) {
        [button setBackgroundColor:[UIColor whiteColor]];
    }else {
        [button setBackgroundColor:[UIColor clearColor]];
    }
}

#pragma mark - CAAnimation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    void(^completion)(void) = [anim valueForKey:@"handler"];
    if (completion) {
        completion();
    }
}

#pragma mark - QLAttributedLabel delegate
- (void)attributedLabel:(QLAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    if (!self.linkBlock) {
        return;
    }
    
    BOOL shouldDismiss = self.linkBlock(url);
    if (shouldDismiss) {
        [self dismissAnimated:YES];
    }
    
}

#pragma mark - UIAppearance setters

//- (void)setViewBackgroundColor:(UIColor *)viewBackgroundColor
//{
//    if (_viewBackgroundColor == viewBackgroundColor) {
//        return;
//    }
//    _viewBackgroundColor = viewBackgroundColor;
//    self.containerView.backgroundColor = viewBackgroundColor;
//}

- (void)setTitleFont:(UIFont *)titleFont
{
    if (_titleFont == titleFont) {
        return;
    }
    _titleFont = titleFont;
    self.titleLabel.font = titleFont;
    [self invaliadateLayout];
}

- (void)setMessageFont:(UIFont *)messageFont
{
    if (_messageFont == messageFont) {
        return;
    }
    _messageFont = messageFont;
    self.messageLabel.font = messageFont;
    [self invaliadateLayout];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    if (_titleColor == titleColor) {
        return;
    }
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setMessageColor:(UIColor *)messageColor
{
    if (_messageColor == messageColor) {
        return;
    }
    _messageColor = messageColor;
    self.messageLabel.textColor = messageColor;
}

- (void)setButtonFont:(UIFont *)buttonFont
{
    if (_buttonFont == buttonFont) {
        return;
    }
    _buttonFont = buttonFont;
    int i = 0;
    for (UIButton *button in self.buttons) {
        button.titleLabel.font = buttonFont;
        if (i < self.items.count)
        {
            SIAlertItem *item = self.items[i];
            if (item.type == SIAlertViewButtonTypeDefault)
                button.titleLabel.font = [UIFont boldSystemFontOfSize:buttonFont.pointSize];
        }
        i++;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
//    if (_cornerRadius == cornerRadius) {
//        return;
//    }
    _cornerRadius = cornerRadius;
    self.containerView.layer.cornerRadius = cornerRadius;
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
//    if (_shadowRadius == shadowRadius) {
//        return;
//    }
    _shadowRadius = shadowRadius;
    self.containerView.layer.shadowRadius = shadowRadius;
}

/*
 *#added by zhangliao
 *#说明：如果accesseryView的长度大于指定限宽，那么需要做适配防止图片被拉伸或者压扁，譬如当accesseryView为一个UIImageView类型的时候  zhangliao (2015/12/02)
 *
 */
- (void)accesseryViewAdaptiveAdjust{
    if (self.accesseryView) {
        BOOL needUpdateSize = NO;
        
        CGFloat tempH = self.accesseryView.height;
        CGFloat tempW = self.accesseryView.width;
        if (self.accesseryView.width > CONTAINER_WIDTH &&
            self.accesseryViewStyle != SIAlertViewAccessaryViewStyleLeft) {
            
            needUpdateSize = YES;
            tempW = CONTAINER_WIDTH;
            
        }
        // 左图右文的模式，图片宽度不能大于弹框的1/3宽   alicejhchen (2016-04-21)
        else if (self.accesseryView.width > CONTAINER_WIDTH / 3.0f &&
            self.accesseryViewStyle == SIAlertViewAccessaryViewStyleLeft) {
            
            needUpdateSize = YES;
            tempW = CONTAINER_WIDTH/3.0f;
        }
        if (needUpdateSize) {
            tempH = tempW * (self.accesseryView.height / self.accesseryView.width); //0 is impossible!
            
            self.accesseryView.size = CGSizeMake(tempW, tempH);
        }
    }
}

- (CGPoint)getAlertViewTopRight
{
    return CGPointMake(self.containerView.right, self.containerView.top);
}

#pragma mark -
#pragma mark otherCustomView
//下面的函数是为了规避向外面暴露过多的内部成员变量所加---begin
- (CGFloat)yOflayoutCustomViewFromY:(CGFloat)y{return y;}
- (CGFloat)heightForOtherView{return 0;}
- (CGFloat)resetYOffset{return 0;}
- (void)updateOtherViewsSuperView:(UIView *)view{}
- (void)resetOtherViews{}
+ (CGFloat)widthOfContainView{return CONTAINER_WIDTH;}
- (UIView *)alertViewContainView
{
    return self.containerView;
}

- (NSArray *)buttonItemArray
{
    return self.buttons;
}

- (CGFloat)containViewBottom
{
    CGFloat height = [self preferredHeight];
    CGFloat left = ceilf((self.bounds.size.width - CONTAINER_WIDTH) * 0.5);
    CGFloat top = ceilf((self.bounds.size.height - height) * 0.5);
    return top + height;
}
//下面的函数是为了规避向外面暴露过多的内部成员变量所加---end
@end
