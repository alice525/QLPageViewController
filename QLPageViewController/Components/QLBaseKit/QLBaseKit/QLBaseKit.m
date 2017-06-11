//
//  QLBaseKit.m
//  QLBaseKit
//
//  Created by Norcy on 2017/4/7.
//  Copyright © 2017年 Norcy. All rights reserved.
//

#import "QLBaseKit.h"

static BOOL isRetina47InchScreen = NO;
static BOOL isRetina55InchScreen = NO;

@implementation QLBaseKit
// 只执行一次
+ (void)initialize
{
    CGFloat screenHeight = [self getScreenHeight];
    if ([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0 && screenHeight == 667)
    {
        isRetina47InchScreen = YES;
    }
    else
    {
        isRetina47InchScreen = NO;
    }

    if ([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 3.0 && screenHeight == 736)
    {
        isRetina55InchScreen = YES;
    }
    else
    {
        isRetina55InchScreen = NO;
    }
}

#pragma mark - ColorView
+ (void)randomColorView:(UIView *)view
{
#ifdef DEBUG
    if ([view isKindOfClass:[UIView class]])
    {
        int r = arc4random() % 255;
        int g = arc4random() % 255;
        int b = arc4random() % 255;
        int a = 1; // 方便断点修改，实现不编译就能控制随机着色的开关
        UIColor *randomColor = [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];
        view.backgroundColor = randomColor;
    }
#endif
}

+ (void)randomColorSubviewsForView:(UIView *)view
{
    if ([view isKindOfClass:[UIView class]])
    {
        [self randomColorView:view];
        [self randomColorViews:view.subviews];
    }
}

+ (void)randomColorViews:(NSArray *)views;
{
    for (int i = 0; i < views.count; i++)
    {
        UIView *view = views[i];
        if ([view isKindOfClass:[UIView class]])
        {
            [self randomColorView:view];
        }
    }
}

#pragma mark - Retina
+ (BOOL)isRetina3P5Inch
{
    CGFloat screenHeight = [self getScreenHeight];
    if ([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0 && screenHeight == 480)
    {
        return YES;
    }
    return NO;
}

+ (BOOL)isRetina4Inch
{
    CGFloat screenHeight = [self getScreenHeight];
    if ([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0 && screenHeight == 568)
    {
        return YES;
    }
    return NO;
}

+ (BOOL)isRetina4Point7Inch
{
    return isRetina47InchScreen;
}

+ (BOOL)isRetina5Point5Inch
{
    return isRetina55InchScreen;
}

#pragma mark - Screen
+ (CGFloat)getScreenWidth
{
    static CGFloat screenWidth = 0;
    if (0 == screenWidth)
    {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        screenWidth = fmin(screenSize.width, screenSize.height);
    }
    return screenWidth;
}

+ (CGFloat)getScreenHeight
{
    static CGFloat screenHeight = 0;
    if (0 == screenHeight)
    {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        screenHeight = fmax(screenSize.width, screenSize.height);
    }
    return screenHeight;
}

#pragma mark - Get Scale Image Size
+ (CGSize)getScaleImageSizeFromImage:(UIImage *)image maxSize:(CGSize)maxSize
{
    if (!image)
    {
        return CGSizeZero;
    }

    CGSize sizeRet = image.size;

    if (sizeRet.width > maxSize.width)
    {
        sizeRet = [self getScaleImageSizeFromImage:image fitWidth:maxSize.width];
    }

    if (sizeRet.height > maxSize.height)
    {
        sizeRet = [self getScaleImageSizeFromImage:image fitHeight:maxSize.height];
    }

    return sizeRet;
}

+ (CGSize)getScaleImageSizeFromImage:(UIImage *)image fitHeight:(CGFloat)height
{
    if (!image)
    {
        return CGSizeZero;
    }

    if (image.size.height <= 0 || image.size.height < 0.0000001)
    {
        return CGSizeZero;
    }

    CGFloat scale = image.size.width / image.size.height;
    return CGSizeMake(height * scale, height);
}

+ (CGSize)getScaleImageSizeFromImage:(UIImage *)image fitWidth:(CGFloat)width
{
    if (!image)
    {
        return CGSizeZero;
    }
    
    if (image.size.width <= 0 || image.size.width < 0.0000001)
    {
        return CGSizeZero;
    }
    
    CGFloat scale = image.size.height / image.size.width;
    return CGSizeMake(width, width * scale);
    
}

@end
