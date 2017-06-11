//
//  QLHTMLFontLabel.h
//  live4iphone
//
//  Created by hengzhuoliu on 21/5/15.
//  Copyright (c) 2015年 Tencent Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRHLabelComponent.h"

// 支持 html font 标签的 label
@interface QLHTMLFontLabel : UILabel

@property (assign) CGFloat htmlFontLineSpacing;

/*
 @parm offset : 高度，宽度偏移
 */
- (void)sizeFit:(CGSize)maxSize offset:(CGPoint)offset;

/**
 不要自己用boundingRect计算文本高度，有两个原因会使计算不准：
    1. text是带html标签的,计算高度应该用去掉html标签的文本计算
    2. 该label自己设置了行间距，boundingRect不会把该行间距计算在内
 所以推荐使用该接口计算高度

  请一定使用autoCaculateAttributedTextSize来计算文本高度，否则会出现文字被截断现象，原因如上所述
 
 @param maxWidth 文本的最大宽度

 @return 文本的size
 */
- (CGSize)autoCaculateAttributedTextSize:(CGSize)maxSize;

@end
