//
//  QLHTMLFontTextView.m
//  QLUIKit
//
//  Created by hengzhuoliu on 23/2/16.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "QLHTMLFontTextView.h"
#import "QRHLabelComponent.h"
#import "NSString+UIColor.h"

@implementation QLHTMLFontTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setText:(NSString *)text {
    QRHLabelExtractedComponent * compnent = [QRHLabelExtractedComponent extractTextStyleFromText:text paragraphReplacement:@""];
    
    if ( !compnent.textComponents.count ) {
        [super setText:text];
    } else {
        // 有样式信息
        
        /* stringByRemovingHTMLTags太暴力，会将 & 后面的字符串去除掉，所以还是使用plainText靠谱  alicejhchen (2016-05-19)
         比如：  2016 <font color="#DDDDDD">|</font> 电影 <font color="#DDDDDD">|</font> 美国 <font color="#DDDDDD">|</font> 英语&普通话
         展示出来的是：2016 | 电影 | 美国 | 英语
         后面的 &普通话 不见了
         */
        NSString * strDesc = compnent.plainText; //[text stringByRemovingHTMLTags];
        if ( strDesc.length ) {
            NSMutableAttributedString * attrbStr = [[NSMutableAttributedString alloc] initWithString:strDesc];
            
            if ( self.font ) {
                [attrbStr addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attrbStr.length)];
            }
            
            //
//            NSMutableParagraphStyle *mParagraphStyle = [[NSMutableParagraphStyle alloc] init];
//            mParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//            [attrbStr addAttribute:NSParagraphStyleAttributeName value:mParagraphStyle range:NSMakeRange(0, attrbStr.length)];
//            
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
                }
            }
            
            self.attributedText = attrbStr;
        } else {
            [super setText:@""];
        }
    }
}

@end
