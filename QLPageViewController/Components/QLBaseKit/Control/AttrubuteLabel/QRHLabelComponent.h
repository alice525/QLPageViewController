//
//  QRHLabelComponent.h
//  QLUIKit
//
//  Created by hengzhuoliu on 23/2/16.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QRHLabelComponent : NSObject
@property (nonatomic, assign) int componentIndex;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *tagLabel;
@property (nonatomic) NSMutableDictionary *attributes;
@property (nonatomic, assign) NSUInteger position;

- (id)initWithString:(NSString*)aText tag:(NSString*)aTagLabel attributes:(NSMutableDictionary*)theAttributes;
+ (id)componentWithString:(NSString*)aText tag:(NSString*)aTagLabel attributes:(NSMutableDictionary*)theAttributes;
- (id)initWithTag:(NSString*)aTagLabel position:(int)_position attributes:(NSMutableDictionary*)_attributes;
+ (id)componentWithTag:(NSString*)aTagLabel position:(int)aPosition attributes:(NSMutableDictionary*)theAttributes;

@end

@interface QRHLabelExtractedComponent : NSObject
@property (nonatomic, strong) NSMutableArray *textComponents;
@property (nonatomic, copy) NSString *plainText;

+ (QRHLabelExtractedComponent*)rtLabelExtractComponentsWithTextComponent:(NSMutableArray*)textComponents plainText:(NSString*)plainText;
+ (QRHLabelExtractedComponent*)extractTextStyleFromText:(NSString*)data paragraphReplacement:(NSString*)paragraphReplacement;
@end
