
//
//  QLHTMLFontLabel.m
//  live4iphone
//
//  Created by hengzhuoliu on 21/5/15.
//  Copyright (c) 2015年 Tencent Inc. All rights reserved.
//

#import "QLHTMLFontLabel.h"
#import "NSString+caculateSize.h"
#import "NSString+UIColor.h"
#import "UIFontAdditions.h"

@interface QLHTMLFontLabel ()

@property (nonatomic, strong) NSMutableParagraphStyle * lineSpaceParagraphStyle;
@property (nonatomic, copy) NSString *plainText;

@end

@implementation QLHTMLFontLabel
@synthesize htmlFontLineSpacing = _htmlFontLineSpacing;

- (void)sizeFit:(CGSize)maxSize offset:(CGPoint)offset {
    if ( self.text.length ) {
        CGSize sz = [self.text sizeWithFont:self.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
        
        self.frame = CGRectMake(0, 0, ceilf(sz.width + offset.x), ceilf(self.font.ascender-self.font.descender-1) + ceilf(offset.y));
    } else {
        self.frame = CGRectZero;
    }
}

- (CGSize)autoCaculateAttributedTextSize:(CGSize)maxSize {
    
    CGSize labelSize = [_plainText ql_sizeForStringWithLineSpacing:self.htmlFontLineSpacing constrainedToSize:maxSize font:self.font maxLineCount:self.numberOfLines];
    
    //对于只有一行文字的Label,需要移除其行间距属性，否则其实际高度比计算高度偏大。
    NSInteger lineNum = ceilf(labelSize.height / self.font.ttLineHeight);
    if (lineNum == 1) {
        NSMutableAttributedString * attrbStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        [attrbStr removeAttribute:NSParagraphStyleAttributeName range:NSMakeRange(0, self.text.length)];
        self.attributedText = attrbStr;
    }
    
    return labelSize;
}

- (id)initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame:frame] ) {
        _htmlFontLineSpacing = 2;
    }
    
    return self;
}

//- (void)setBackgroundColor:(UIColor *)backgroundColor {
//    [super setBackgroundColor:[UIColor clearColor]];
//    
//    self.layer.backgroundColor = backgroundColor.CGColor;
//}

//- (void)setPersistentBackgroundColor:(UIColor*)color {
//    super.backgroundColor = color;
//}

//- (void)setBackgroundColor:(UIColor *)color {
//    // do nothing - background color never changes
//}


/**
 注意：设置numberOfLines属性一定要在 setText之前，因为设置文本颜色需要用到numberOfLines，否则无法显示出文本的颜色

 */
- (void)setText:(NSString *)text {
    QRHLabelExtractedComponent * compnent = [QRHLabelExtractedComponent extractTextStyleFromText:text paragraphReplacement:@""];
    
    self.plainText = compnent.plainText;
    
    if ( !compnent.textComponents.count ) {
        if ( self.numberOfLines >= 0 ) {
            // 2行需要设置行间距
            NSMutableAttributedString * attrbStr = [[NSMutableAttributedString alloc] initWithString:text];
            
            if ( !self.lineSpaceParagraphStyle ) {
                self.lineSpaceParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                self.lineSpaceParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;//NSLineBreakByWordWrapping;
                self.lineSpaceParagraphStyle.lineSpacing = self.htmlFontLineSpacing;
            }
            [self.lineSpaceParagraphStyle setAlignment:self.textAlignment];
            
            [attrbStr addAttribute:NSParagraphStyleAttributeName value:self.lineSpaceParagraphStyle range:NSMakeRange(0, text.length)];
            
            self.attributedText = attrbStr;
        } else {
            self.lineBreakMode = NSLineBreakByTruncatingTail;
            [super setText:text];
        }
    } else {
        // 有样式信息
        
        /* stringByRemovingHTMLTags太暴力，会将 & 后面的字符串去除掉，所以还是使用plainText靠谱  alicejhchen (2016-05-19)
           比如：  2016 <font color="#DDDDDD">|</font> 电影 <font color="#DDDDDD">|</font> 美国 <font color="#DDDDDD">|</font> 英语&普通话
           展示出来的是：2016 | 电影 | 美国 | 英语
           后面的 &普通话 不见了
         */
        //NSString * strDesc = [text stringByRemovingHTMLTags];
        NSString * strDesc = compnent.plainText;
        if ( strDesc.length ) {
            NSMutableAttributedString * attrbStr = [[NSMutableAttributedString alloc] initWithString:strDesc];
            
            if ( self.numberOfLines >= 0 ) {
                
                if ( !self.lineSpaceParagraphStyle ) {
                    self.lineSpaceParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                    self.lineSpaceParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;//NSLineBreakByWordWrapping;
                    self.lineSpaceParagraphStyle.lineSpacing = self.htmlFontLineSpacing;
                }
                [self.lineSpaceParagraphStyle setAlignment:self.textAlignment];
                [attrbStr addAttribute:NSParagraphStyleAttributeName value:self.lineSpaceParagraphStyle range:NSMakeRange(0, strDesc.length)];
            } else {
                self.lineBreakMode = NSLineBreakByTruncatingTail;
            }
            
            for ( QRHLabelComponent * tCompnent in compnent.textComponents ) {
                if ( [tCompnent.tagLabel isEqualToString:@"font"] ) {
                    NSDictionary * txtAttrib = tCompnent.attributes;
                    NSString * color = [txtAttrib objectForKey:@"color"];
                    if ( color.length ) {
                        // 只认颜色
                        NSRange txtRng = NSMakeRange(tCompnent.position, tCompnent.text.length);
                        if ( txtRng.location + txtRng.length <= strDesc.length ) {
                            [attrbStr addAttribute:NSForegroundColorAttributeName value:[color toUIColor] range:NSMakeRange(tCompnent.position, tCompnent.text.length)];
                        }
                    }
                    
                    NSString *bold = [txtAttrib objectForKey:@"bold"];
                    if (bold.length) {
                        UIFont *boldFont = [UIFont boldSystemFontOfSize:self.font.pointSize];
                        
                        NSRange txtRng = NSMakeRange(tCompnent.position, tCompnent.text.length);
                        if ( txtRng.location + txtRng.length <= strDesc.length ) {
                            [attrbStr addAttribute:NSFontAttributeName value:boldFont range:txtRng];
                        }
                        
                        
                    }
                }
            }
            
            self.attributedText = attrbStr;
        } else {
            [super setText:@""];
        }
    }
}

@end
