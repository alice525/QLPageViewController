//
//  NSString+caculateSize.h
//  live4iphone
//
//  Created by alicejhchen on 16/10/13.
//  Copyright © 2016年 Tencent Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (caculateSize)

- (CGSize)ql_sizeForStringWithLineSpacing:(NSInteger)lineSpacing constrainedToSize:(CGSize)size font:(UIFont *)font maxLineCount:(NSInteger)maxLineCount;

@end
