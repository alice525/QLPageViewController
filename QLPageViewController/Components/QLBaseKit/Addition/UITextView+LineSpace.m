//
//  UITextView+LineSpace.m
//  QLBaseCore
//
//  Created by Norcy on 16/8/31.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "UITextView+LineSpace.h"
#import "NSStringAdditions.h"

@implementation UITextView (LineSpace)
- (void)setText:(NSString *)text lineSpacing:(CGFloat)lineSpacing
{
    if (!text)
    {
        self.text = text;
        return;
    }

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, [text length])];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];

    self.attributedText = attributedString;
    self.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (CGFloat)heightWithMaxWidth:(CGFloat)width lineSpacing:(CGFloat)lineSpacing maxLine:(NSUInteger)maxLine
{
    NSString *text = [self.text stringByRemovingHTMLTags];
    return [[self class] text:text
           heightWithFontSize:self.font.pointSize
                        width:width
                  lineSpacing:lineSpacing
                      maxLine:maxLine
                 contentInset:self.textContainerInset
                      padding:self.textContainer.lineFragmentPadding];
}

+ (CGFloat)text:(NSString *)text heightWithFontSize:(CGFloat)fontSize width:(CGFloat)width lineSpacing:(CGFloat)lineSpacing maxLine:(NSUInteger)maxLine
   contentInset:(UIEdgeInsets)contentInset padding:(CGFloat)padding
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width, CGFLOAT_MAX)];
    textView.textContainer.maximumNumberOfLines = maxLine;
    textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    textView.font = [UIFont systemFontOfSize:fontSize];
    textView.textContainerInset = contentInset;
    textView.textContainer.lineFragmentPadding = padding;
    [textView setText:text lineSpacing:lineSpacing];
    [textView sizeToFit];
    return ceilf(textView.bounds.size.height);
}

@end
