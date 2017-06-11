//
// MBProgressHUD.m
// Version 0.4
// Created by Matej Bukovinski on 2.4.09.
//

#import "QLMBProgressHUD.h"
#import "QLBaseKit.h"

@interface QLMBProgressHUD ()
{
    BOOL _disappearWhenTouchScreen;
    UIControl *_touchMaskLayer;
}

- (void)hideUsingAnimation:(BOOL)animated;
- (void)showUsingAnimation:(BOOL)animated;
- (void)done;
- (void)updateLabelText:(NSString *)newText;
- (void)updateDetailsLabelText:(NSString *)newText;
- (void)updateProgress;
- (void)updateIndicators;
- (void)handleGraceTimer:(NSTimer *)theTimer;
- (void)handleMinShowTimer:(NSTimer *)theTimer;
- (void)setTransformForCurrentOrientation:(BOOL)animated;
- (void)cleanUp;
- (void)deviceOrientationDidChange:(NSNotification *)notification;
- (void)hideDelayed:(NSNumber *)animated;
- (void)launchExecution;

@property (retain) UIView *indicator;
@property (assign) float width;
@property (assign) float height;
@property (retain) NSTimer *graceTimer;
@property (retain) NSTimer *minShowTimer;
@property (retain) NSDate *showStarted;

@end


@implementation QLMBProgressHUD

#pragma mark -
#pragma mark Accessors

@synthesize animationType;

@synthesize delegate;
@synthesize opacity;
@synthesize labelFont;
@synthesize detailsLabelFont;

@synthesize indicator;

@synthesize width;
@synthesize height;
@synthesize xOffset;
@synthesize yOffset;
@synthesize minSize;
@synthesize margin;
@synthesize dimBackground;

@synthesize graceTime;
@synthesize minShowTime;
@synthesize graceTimer;
@synthesize minShowTimer;
@synthesize taskInProgress;
@synthesize removeFromSuperViewOnHide;

@synthesize customView;
@synthesize showStarted;

@synthesize radius;

- (void)setMode:(MBProgressHUDMode)newMode {
    // Dont change mode if it wasn't actually changed to prevent flickering
    if (mode && (mode == newMode)) {
        return;
    }
    
    mode = newMode;
    
    if ([NSThread isMainThread]) {
        [self updateIndicators];
        [self setNeedsLayout];
        [self setNeedsDisplay];
    } else {
        [self performSelectorOnMainThread:@selector(updateIndicators) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    }
}

- (MBProgressHUDMode)mode {
    return mode;
}

- (void)setLabelText:(NSString *)newText {
    if ([NSThread isMainThread]) {
        [self updateLabelText:newText];
        [self setNeedsLayout];
        [self setNeedsDisplay];
    } else {
        [self performSelectorOnMainThread:@selector(updateLabelText:) withObject:newText waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    }
}

- (NSString *)labelText {
    return labelText;
}

- (void)setDetailsLabelText:(NSString *)newText {
    if ([NSThread isMainThread]) {
        [self updateDetailsLabelText:newText];
        [self setNeedsLayout];
        [self setNeedsDisplay];
    } else {
        [self performSelectorOnMainThread:@selector(updateDetailsLabelText:) withObject:newText waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    }
}

- (NSString *)detailsLabelText {
    return detailsLabelText;
}

- (void)setProgress:(float)newProgress {
    progress = newProgress;
    
    // Update display ony if showing the determinate progress view
    if (mode == MBProgressHUDModeDeterminate) {
        if ([NSThread isMainThread]) {
            [self updateProgress];
            [self setNeedsDisplay];
        } else {
            [self performSelectorOnMainThread:@selector(updateProgress) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
        }
    }
}

- (float)progress {
    return progress;
}

- (IBAction)onTouchDisappearScreen:(id)sender {
    if (_touchMaskLayer != nil) {
        [_touchMaskLayer removeFromSuperview];
        _touchMaskLayer = nil;
    }
    
    [self hideUsingAnimation:NO];
}

- (void)setDisappearWhenTouchScreen:(BOOL)value
{
    _disappearWhenTouchScreen = value;
    if (_disappearWhenTouchScreen) {
        if (_touchMaskLayer == nil) {
            _touchMaskLayer = [[UIControl alloc] initWithFrame:self.bounds];
            _touchMaskLayer.alpha = 0.1;
            _touchMaskLayer.backgroundColor = [UIColor clearColor];
            _touchMaskLayer.userInteractionEnabled = YES;
            [_touchMaskLayer addTarget:self action:@selector(onTouchDisappearScreen:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_touchMaskLayer];
        }
    }
    else {
        if (_touchMaskLayer != nil) {
            [_touchMaskLayer removeFromSuperview];
            _touchMaskLayer = nil;
        }
    }
}

- (BOOL)disappearWhenTouchScreen
{
    return _disappearWhenTouchScreen;
}

#pragma mark -
#pragma mark Accessor helpers

- (void)updateLabelText:(NSString *)newText {
    if (labelText != newText) {
        labelText = [newText copy];
    }
}

- (void)updateDetailsLabelText:(NSString *)newText {
    if (detailsLabelText != newText) {
        detailsLabelText = [newText copy];
    }
}

- (void)updateProgress {
    [(QLMBRoundProgressView *)indicator setProgress:progress];
}

- (void)updateIndicators {
    if (indicator) {
        [indicator removeFromSuperview];
    }
    
    if (mode == MBProgressHUDModeDeterminate) {
        self.indicator = [[QLMBRoundProgressView alloc] init];
    }
    else if (mode == MBProgressHUDModeCustomView && self.customView != nil){
        self.indicator = self.customView;
    }
    else if (mode == MBProgressHUDModeTextView){
        self.indicator = nil;
    } else {
        self.indicator = [[UIActivityIndicatorView alloc]
                           initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [(UIActivityIndicatorView *)indicator startAnimating];
    }
    
    
    [self addSubview:indicator];
}

#pragma mark -
#pragma mark Constants

#define PADDING 4.0f

#define LABELFONTSIZE 14.0f
#define LABELDETAILSFONTSIZE 12.0f

#pragma mark -
#pragma mark Class methods

+ (QLMBProgressHUD *)showHUDAddedTo:(UIView *)view animated:(BOOL)animated {
    QLMBProgressHUD *hud = [[QLMBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    [hud show:animated];
    return hud;
}

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated {
    UIView *viewToRemove = nil;
    for (UIView *v in [view subviews]) {
        if ([v isKindOfClass:[QLMBProgressHUD class]]) {
            viewToRemove = v;
        }
    }
    if (viewToRemove != nil) {
        QLMBProgressHUD *HUD = (QLMBProgressHUD *)viewToRemove;
        HUD.removeFromSuperViewOnHide = YES;
        [HUD hide:animated];
        return YES;
    } else {
        return NO;
    }
}


#pragma mark -
#pragma mark Lifecycle methods

- (id)initWithWindow:(UIWindow *)window {
    return [self initWithView:window];
}

- (id)initWithView:(UIView *)view {
    // Let's check if the view is nil (this is a common error when using the windw initializer above)
    if (!view) {
        [NSException raise:@"MBProgressHUDViewIsNillException"
                    format:@"The view used in the MBProgressHUD initializer is nil."];
    }
    
    // by jeff, (id me = [self initWithFrame:] --> self = [self initWithFrame:])
    self = [self initWithFrame:view.bounds];
    // We need to take care of rotation ourselfs if we're adding the HUD to a window
    if ([view isKindOfClass:[UIWindow class]]) {
        [self setTransformForCurrentOrientation:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Set default values for properties
        self.animationType = MBProgressHUDAnimationFade;
        self.mode = MBProgressHUDModeIndeterminate;
        self.labelText = nil;
        self.detailsLabelText = nil;
        self.opacity = 0.9f;
        self.labelFont = [UIFont systemFontOfSize:LABELFONTSIZE];//[UIFont boldSystemFontOfSize:LABELFONTSIZE];
        self.detailsLabelFont = [UIFont systemFontOfSize:LABELDETAILSFONTSIZE];//[UIFont boldSystemFontOfSize:LABELDETAILSFONTSIZE];
        self.xOffset = 0.0f;
        self.yOffset = 0.0f;
        self.dimBackground = NO;
        self.margin = 15.0f;
        self.graceTime = 0.0f;
        self.minShowTime = 0.0f;
        self.removeFromSuperViewOnHide = NO;
        self.minSize = CGSizeZero;
        self.tag = MBProgressHUDViewTag;

        self.marginX = 20;
        self.marginY = 15;
        CGFloat rate = 270.0 / 375.0;
        self.maxWidth = [QLBaseKit getScreenWidth] * rate;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        self.layer.shadowOpacity = 0.35;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        // Transparent background
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        // Make invisible for now
        self.alpha = 0.0f;
        
        // Add label
        label = [[UILabel alloc] initWithFrame:self.bounds];
        
        // Add details label
        detailsLabel = [[UILabel alloc] initWithFrame:self.bounds];
        
        taskInProgress = NO;
        rotationTransform = CGAffineTransformIdentity;
        
        radius = 6.0f;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_touchMaskLayer removeFromSuperview];
}

#pragma mark -
#pragma mark Layout

- (void)layoutSubviews {
    CGRect frame = self.bounds;
    
    // Compute HUD dimensions based on indicator size (add margin to HUD border)
    CGRect indFrame = indicator.bounds;
    self.width = indFrame.size.width + 2 * _marginX;
    self.height = indFrame.size.height + 2 * _marginY;
    
    // Position the indicator
    indFrame.origin.x = floorf((frame.size.width - indFrame.size.width) / 2) + self.xOffset;
    indFrame.origin.y = floorf((frame.size.height - indFrame.size.height) / 2) + self.yOffset;
    indicator.frame = indFrame;
    
    // Add label if label text was set
    if (nil != self.labelText) {
        // Get size of label text
        CGSize dims = [self.labelText sizeWithFont:self.labelFont constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
        CGFloat constrainedTextWidth = _maxWidth-_marginX*2;//frame.size.width-10
        if (self.multiLine)
        {
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.numberOfLines = 5;
            constrainedTextWidth = _maxWidth-_marginX * 2;//frame.size.width-_marginX * 2;
            dims = [self.labelText sizeWithFont:self.labelFont constrainedToSize:CGSizeMake(constrainedTextWidth, CGFLOAT_MAX) lineBreakMode:label.lineBreakMode];
        }
        
        /** 这里可能存在一个漏洞：numberOfLines设定的为5，计算label高度的时候，用的是CGFLOAT_MAX，那么当文本超过10行的时候，会不会出现label高度为10行，但只展示了5行的情况？
            noted by zhangliao(2016/06/02)
         **/
        
        // Compute label dimensions based on font metrics if size is larger than max then clip the label width
        float lHeight = dims.height;
        float lWidth;
        if (dims.width <= constrainedTextWidth) {//frame.size.width-_marginX * 2
            lWidth = dims.width;
        }
        else {
            lWidth = constrainedTextWidth;//frame.size.width - 4 * _marginX;
        }
        
        // Set label properties
        label.font = self.labelFont;
        label.adjustsFontSizeToFitWidth = NO;
        label.textAlignment = NSTextAlignmentCenter;
        label.opaque = NO;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = self.labelText;
        
        // Update HUD size
        if (self.width < (lWidth + 2 * _marginX)) {
            self.width = lWidth + 2 * _marginX;
        }
        
        //如果没有indicator则不加Padding Norcy(20151212)
        if ([self hasIndicator])
            self.height = self.height + lHeight + PADDING;
        else
            self.height = self.height + lHeight;
        
        if (mode == MBProgressHUDModeTextView) {
            label.numberOfLines = 0;
        }
        //如果有indicator才更新frame Norcy(20151212)
        if ([self hasIndicator])
        {
            // Move indicator to make room for the label
            indFrame.origin.y -= (floorf(lHeight / 2 + PADDING / 2));
            indicator.frame = indFrame;
        }
        
        CGSize textSize = [label.text sizeWithFont:label.font
                                 constrainedToSize:CGSizeMake(constrainedTextWidth, CGFLOAT_MAX)
                                     lineBreakMode:label.lineBreakMode];
        // 考虑视觉，两个控件之间留下一点间距，tencent:jiachunke(20140823)
        //float textTop = floorf(indFrame.origin.y + indFrame.size.height);
        CGFloat textTop;
        //有无indicator区分来判断 Norcy(20151212)
        if ([self hasIndicator])
        {
            textTop = indFrame.origin.y + indFrame.size.height + 8;
        }
        else
        {
            textTop = (frame.size.height - textSize.height) / 2 + self.yOffset;
        }
        
        float textWidth = textSize.width;
        if (mode == MBProgressHUDModeTextView) {
            lWidth = textSize.width;
            textTop = 20;
            label.textAlignment = NSTextAlignmentLeft;
        }
        // Set the label position and dimensions
        CGRect lFrame = CGRectMake((frame.size.width - lWidth) / 2 + xOffset,   //不取整否则有误差
                                   indFrame.origin.y + indFrame.size.height + PADDING, //不取整否则有误差
                                   lWidth, lHeight);
        label.frame = CGRectMake((frame.size.width - lWidth) / 2/* + 5*/,   //不取整否则有误差
                                 textTop, textWidth, textSize.height);
        
        [self addSubview:label];
        
        // Add details label delatils text was set
        if (nil != self.detailsLabelText) {
            // Get size of label text
            dims = [self.detailsLabelText sizeWithFont:self.detailsLabelFont constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
            
            // Compute label dimensions based on font metrics if size is larger than max then clip the label width
            lHeight = dims.height;
            if (dims.width <= (frame.size.width - 2 * _marginX)) {
                lWidth = dims.width;
            }
            else {
                lWidth = frame.size.width - 4 * _marginX;
            }
            
            // Set label properties
            detailsLabel.font = self.detailsLabelFont;
            detailsLabel.adjustsFontSizeToFitWidth = NO;
            detailsLabel.textAlignment = NSTextAlignmentCenter;
            detailsLabel.opaque = NO;
            detailsLabel.backgroundColor = [UIColor clearColor];
            detailsLabel.textColor = [UIColor whiteColor];
            detailsLabel.text = self.detailsLabelText;
            
            // Update HUD size
            if (self.width < lWidth) {
                self.width = lWidth + 2 * _marginX;
            }
            self.height = self.height + lHeight + PADDING;
            
            // Move indicator to make room for the new label
            indFrame.origin.y -= (floorf(lHeight / 2 + PADDING / 2));
            indicator.frame = indFrame;
            
            // Move first label to make room for the new label
            lFrame.origin.y -= (floorf(lHeight / 2 + PADDING / 2));
            label.frame = lFrame;
            
            // Set label position and dimensions
            CGRect lFrameD = CGRectMake(floorf((frame.size.width - lWidth) / 2) + xOffset,
                                        lFrame.origin.y + lFrame.size.height + PADDING, lWidth, lHeight);
            detailsLabel.frame = lFrameD;
            
            [self addSubview:detailsLabel];
        }
    }else {
        label.text = @"";
        label.frame = CGRectZero;
        if ([self hasIndicator]) {
            indFrame = indicator.bounds;
            self.width = indFrame.size.width + 2 * (_marginX + 2.5);
            self.height = indFrame.size.height + 2 * (_marginY - 3);
        }
    }
    
    if (self.width < minSize.width) {
        self.width = minSize.width;
    }
    if (self.height < minSize.height) {
        self.height = minSize.height;
    }
}

- (BOOL)hasIndicator
{
    return (indicator.frame.size.height != 0 && indicator.frame.size.width != 0);
}

#pragma mark -
#pragma mark Showing and execution

- (void)show:(BOOL)animated {
    useAnimation = animated;
    
    // If the grace time is set postpone the HUD display
    if (self.graceTime > 0.0) {
        self.graceTimer = [NSTimer scheduledTimerWithTimeInterval:self.graceTime
                                                           target:self
                                                         selector:@selector(handleGraceTimer:)
                                                         userInfo:nil
                                                          repeats:NO];
    }
    // ... otherwise show the HUD imediately
    else {
        [self setNeedsDisplay];
        [self showUsingAnimation:useAnimation];
    }
}

- (void)cancelPreviousDelayHide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideDelayed:) object:[NSNumber numberWithBool:3]];
}
- (void)hide:(BOOL)animated {
    useAnimation = animated;
    
    // If the minShow time is set, calculate how long the hud was shown,
    // and pospone the hiding operation if necessary
    if (self.minShowTime > 0.0 && showStarted) {
        NSTimeInterval interv = [[NSDate date] timeIntervalSinceDate:showStarted];
        if (interv < self.minShowTime) {
            self.minShowTimer = [NSTimer scheduledTimerWithTimeInterval:(self.minShowTime - interv)
                                                                 target:self
                                                               selector:@selector(handleMinShowTimer:)
                                                               userInfo:nil
                                                                repeats:NO];
            return;
        }
    }
    
    // ... otherwise hide the HUD immediately
    [self hideUsingAnimation:useAnimation];
}

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(hideDelayed:) withObject:[NSNumber numberWithBool:delay] afterDelay:delay];
}

- (void)hideDelayed:(NSNumber *)animated {
    [self hide:[animated boolValue]];
}

- (void)handleGraceTimer:(NSTimer *)theTimer {
    // Show the HUD only if the task is still running
    if (taskInProgress) {
        [self setNeedsDisplay];
        [self showUsingAnimation:useAnimation];
    }
}

- (void)handleMinShowTimer:(NSTimer *)theTimer {
    [self hideUsingAnimation:useAnimation];
}

- (void)showWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated {
    
    methodForExecution = method;
    targetForExecution = target;
    objectForExecution = object;
    
    // Launch execution in new thread
    taskInProgress = YES;
    [NSThread detachNewThreadSelector:@selector(launchExecution) toTarget:self withObject:nil];
    
    // Show HUD view
    [self show:animated];
}

- (void)launchExecution {

    // Start executing the requested task
    [targetForExecution performSelector:methodForExecution withObject:objectForExecution];
    
    // Task completed, update view in main thread (note: view operations should
    // be done only in the main thread)
    [self performSelectorOnMainThread:@selector(cleanUp) withObject:nil waitUntilDone:NO];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context {
    [self done];
}

- (void)done {
    isFinished = YES;
    
    // If delegate was set make the callback
    self.alpha = 0.0f;
    
    if(delegate != nil) {
        if ([delegate respondsToSelector:@selector(hudWasHidden:)]) {
            [delegate performSelector:@selector(hudWasHidden:) withObject:self];
        } else if ([delegate respondsToSelector:@selector(hudWasHidden)]) {
            [delegate performSelector:@selector(hudWasHidden)];
        }
    }
    
    if (removeFromSuperViewOnHide) {
        [self removeFromSuperview];
    }
}

- (void)cleanUp {
    taskInProgress = NO;
    
    self.indicator = nil;
    
    [self hide:useAnimation];
}

#pragma mark -
#pragma mark Fade in and Fade out

- (void)showUsingAnimation:(BOOL)animated {
    self.alpha = 0.0f;
    if (animated && animationType == MBProgressHUDAnimationZoom) {
        self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
    }
    
    self.showStarted = [NSDate date];
    // Fade in
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        self.alpha = 1.0f;
        if (animationType == MBProgressHUDAnimationZoom) {
            self.transform = rotationTransform;
        }
        [UIView commitAnimations];
    }
    else {
        self.alpha = 1.0f;
    }
}

- (void)hideUsingAnimation:(BOOL)animated {
    // Fade out
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationFinished: finished: context:)];
        // 0.02 prevents the hud from passing through touches during the animation the hud will get completely hidden
        // in the done method
        if (animationType == MBProgressHUDAnimationZoom) {
            self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
        }
        self.alpha = 0.02f;
        [UIView commitAnimations];
    }
    else {
        self.alpha = 0.0f;
        [self done];
    }
    
    //added by zhangliao(2016/05//13 V4.8.5)
    if (nil != self.hideDoneCompletion) {
        self.hideDoneCompletion();
        self.hideDoneCompletion = nil;
    }
}

#pragma mark BG Drawing

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    if (dimBackground) {
//        //Gradient colours
//        size_t gradLocationsNum = 2;
//        CGFloat gradLocations[2] = {0.0f, 1.0f};
//        CGFloat gradColors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
//        CGColorSpaceRelease(colorSpace);
//        
//        //Gradient center
//        CGPoint gradCenter= CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
//        //Gradient radius
//        float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
//        //Gradient draw
//        CGContextDrawRadialGradient (context, gradient, gradCenter,
//                                     0, gradCenter, gradRadius,
//                                     kCGGradientDrawsAfterEndLocation);
//        CGGradientRelease(gradient);
//    }
    
    // Center HUD
    CGRect allRect = self.bounds;
    // Draw rounded HUD bacgroud rect
    CGRect boxRect = CGRectMake((allRect.size.width - self.width) / 2 + self.xOffset,   //不取整否则有误差
                                (allRect.size.height - self.height) / 2 + self.yOffset, self.width, self.height);   //不取整否则有误差
    if (mode == MBProgressHUDModeTextView) {
        boxRect = allRect;
    }
    // Corner radius
    //	float radius = 10.0f;
    
    CGContextBeginPath(context);
    CGContextSetGrayFillColor(context, 0.0f, self.opacity);
    CGContextMoveToPoint(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect));
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMinY(boxRect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMaxY(boxRect) - radius, radius, 0, (float)M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMaxY(boxRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect) + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

#pragma mark -
#pragma mark Manual oritentation change

#define RADIANS(degrees) ((degrees * (float)M_PI) / 180.0f)

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    if (!self.superview) {
        return;
    }
    if ([self.superview isKindOfClass:[UIWindow class]]) {
        [self setTransformForCurrentOrientation:YES];
    }
}

- (void)setTransformForCurrentOrientation:(BOOL)animated {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    NSInteger degrees = 0;
    
    // Stay in sync with the superview
    if (self.superview) {
        self.bounds = self.superview.bounds;
        [self setNeedsDisplay];
    }
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (orientation == UIInterfaceOrientationLandscapeLeft) { degrees = -90; }
        else { degrees = 90; }
        // Window coordinates differ!
        self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    } else {
        if (orientation == UIInterfaceOrientationPortraitUpsideDown) { degrees = 180; }
        else { degrees = 0; }
    }
    
    rotationTransform = CGAffineTransformMakeRotation(RADIANS(degrees));
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
    }
    [self setTransform:rotationTransform];
    if (animated) {
        [UIView commitAnimations];
    }
}

@end

/////////////////////////////////////////////////////////////////////////////////////////////

@implementation QLMBRoundProgressView

#pragma mark -
#pragma mark Accessors

- (float)progress {
    return _progress;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Lifecycle

- (id)init {
    return [self initWithFrame:CGRectMake(0.0f, 0.0f, 37.0f, 37.0f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
    
    CGRect allRect = self.bounds;
    CGRect circleRect = CGRectInset(allRect, 2.0f, 2.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw background
    CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // white
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 0.1f); // translucent white
    CGContextSetLineWidth(context, 2.0f);
    CGContextFillEllipseInRect(context, circleRect);
    CGContextStrokeEllipseInRect(context, circleRect);
    
    // Draw progress
    CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
    CGFloat radius = (allRect.size.width - 4) / 2;
    CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
    CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // white
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

@end

/////////////////////////////////////////////////////////////////////////////////////////////
