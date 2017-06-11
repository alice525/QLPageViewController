//
//  UITextView+LineSpace.h
//  QLBaseCore
//
//  Created by Norcy on 16/8/31.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (LineSpace)
- (void)setText:(NSString *)text lineSpacing:(CGFloat)lineSpacing;
- (CGFloat)heightWithMaxWidth:(CGFloat)width lineSpacing:(CGFloat)lineSpacing maxLine:(NSUInteger)maxLine;
+ (CGFloat)text:(NSString *)text heightWithFontSize:(CGFloat)fontSize width:(CGFloat)width lineSpacing:(CGFloat)lineSpacing maxLine:(NSUInteger)maxLine
   contentInset:(UIEdgeInsets)contentInset padding:(CGFloat)padding;
@end
