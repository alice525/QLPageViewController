//
//  NSString+caculateSize.m
//  live4iphone
//
//  Created by alicejhchen on 16/10/13.
//  Copyright © 2016年 Tencent Inc. All rights reserved.
//

#import "NSString+caculateSize.h"
#import "UIFontAdditions.h"

@implementation NSString (caculateSize)

- (CGSize)ql_sizeForStringWithLineSpacing:(NSInteger)lineSpacing constrainedToSize:(CGSize)size font:(UIFont *)font maxLineCount:(NSInteger)maxLineCount {
    // boundingRect不会将行间距也计算在内，所以需要根据文本行数自己计算文本高度
    CGRect rect = [self boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName:font} context:nil];
    
    NSInteger lineNum = ceilf(rect.size.height / font.ttLineHeight);
    
    NSInteger realLineNum = maxLineCount? MIN(maxLineCount, lineNum) : lineNum;
    
    return CGSizeMake(ceilf(rect.size.width), font.ttLineHeight * realLineNum + (realLineNum - 1) * lineSpacing);
}

@end
