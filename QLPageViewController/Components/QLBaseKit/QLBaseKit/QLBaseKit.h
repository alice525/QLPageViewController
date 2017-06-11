//
//  QLBaseKit.h
//  QLBaseKit
//
//  Created by Norcy on 2017/4/7.
//  Copyright © 2017年 Norcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef RGBCOLOR
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#endif
#ifndef RGBACOLOR
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]
#endif

#define DECLARE_WEAK_SELF __typeof(&*self) __weak weakSelf = self
#define DECLARE_STRONG_SELF __typeof(&*self) __strong strongSelf = weakSelf

@interface QLBaseKit : NSObject
#pragma mark - ColorView
#define ColorView(view) [QLBaseKit randomColorView:view]
#define ColorViews(views) [QLBaseKit randomColorViews:views]
#define ColorSubviews(view) [QLBaseKit randomColorSubviewsForView:view]
+ (void)randomColorView:(UIView *)view;
+ (void)randomColorViews:(NSArray *)views;
+ (void)randomColorSubviewsForView:(UIView *)view;

+ (BOOL)isRetina3P5Inch;
+ (BOOL)isRetina4Inch;
+ (BOOL)isRetina4Point7Inch;
+ (BOOL)isRetina5Point5Inch;
+ (CGFloat)getScreenWidth;
+ (CGFloat)getScreenHeight;

#pragma mark - Get Scale Image Size
// 指定最大Size，根据图片的大小返回合适的Size
+ (CGSize)getScaleImageSizeFromImage:(UIImage *)image maxSize:(CGSize)maxSize;
// 指定高度，根据图片返回合适的Size
+ (CGSize)getScaleImageSizeFromImage:(UIImage *)image fitHeight:(CGFloat)height;
// 指定宽度，根据图片返回合适的Size
+ (CGSize)getScaleImageSizeFromImage:(UIImage *)image fitWidth:(CGFloat)width;

@end
