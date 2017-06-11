//
//  QRHLabelComponent.m
//  QLUIKit
//
//  Created by hengzhuoliu on 23/2/16.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "QRHLabelComponent.h"

@implementation QRHLabelComponent

- (id)initWithString:(NSString*)aText tag:(NSString*)aTagLabel attributes:(NSMutableDictionary*)theAttributes
{
    self = [super init];
    if (self) {
        _text = aText;
        _tagLabel = aTagLabel;
        _attributes = theAttributes;
    }
    return self;
}

+ (id)componentWithString:(NSString*)aText tag:(NSString*)aTagLabel attributes:(NSMutableDictionary*)theAttributes
{
    return [[self alloc] initWithString:aText tag:aTagLabel attributes:theAttributes];
}

- (id)initWithTag:(NSString*)aTagLabel position:(int)aPosition attributes:(NSMutableDictionary*)theAttributes
{
    self = [super init];
    if (self) {
        _tagLabel = aTagLabel;
        _position = aPosition;
        _attributes = theAttributes;
    }
    return self;
}

+ (id)componentWithTag:(NSString*)aTagLabel position:(int)aPosition attributes:(NSMutableDictionary*)theAttributes
{
    // 因为整个项目有两个相同的方法名，编译器无法足够智能地选择使用上面那个方法，报错，tencent:jiachunke(20150703)
    //return [[self alloc] initWithTag:aTagLabel position:aPosition attributes:theAttributes];
    return [[QRHLabelComponent alloc] initWithTag:aTagLabel position:aPosition attributes:theAttributes];
}

- (NSString*)description
{
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"text: %@", self.text];
    [desc appendFormat:@", position: %tu", self.position];
    if (self.tagLabel) [desc appendFormat:@", tag: %@", self.tagLabel];
    if (self.attributes) [desc appendFormat:@", attributes: %@", self.attributes];
    return desc;
}

@end

@implementation QRHLabelExtractedComponent

+ (QRHLabelExtractedComponent*)rtLabelExtractComponentsWithTextComponent:(NSMutableArray*)textComponents plainText:(NSString*)plainText
{
    QRHLabelExtractedComponent *component = [[QRHLabelExtractedComponent alloc] init];
    [component setTextComponents:textComponents];
    [component setPlainText:plainText];
    return component;
}

+ (QRHLabelExtractedComponent*)extractTextStyleFromText:(NSString*)data paragraphReplacement:(NSString*)paragraphReplacement
{
    NSScanner *scanner = nil;
    NSString *text = nil;
    NSString *tag = nil;
    
    NSMutableArray *components = [NSMutableArray array];
    
    NSUInteger last_position = 0;
    scanner = [NSScanner scannerWithString:data];
    while (![scanner isAtEnd])
    {
        [scanner scanUpToString:@"<" intoString:NULL];
        [scanner scanUpToString:@">" intoString:&text];
        
        NSString *delimiter = [NSString stringWithFormat:@"%@>", text];
        NSUInteger position = [data rangeOfString:delimiter].location;
        
        if ( position!=NSNotFound)
        {
            if ([delimiter rangeOfString:@"<p"].location==0)
            {
                data = [data stringByReplacingOccurrencesOfString:delimiter withString:paragraphReplacement options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position+delimiter.length-last_position)];
            }
            else
            {
                data = [data stringByReplacingOccurrencesOfString:delimiter withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position+delimiter.length-last_position)];
            }
            
            data = [data stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
            data = [data stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        }
        
        if ([text rangeOfString:@"</"].location==0)
        {
            // end of tag
            tag = [text substringFromIndex:2];
            if (position!=NSNotFound)
            {
                for (int i=(int)[components count]-1; i>=0; i--)
                {
                    QRHLabelComponent *component = [components objectAtIndex:i];
                    if (component.text==nil && [component.tagLabel isEqualToString:tag])
                    {
                        NSString *text2 = [data substringWithRange:NSMakeRange(component.position, position-component.position)];
                        component.text = text2;
                        break;
                    }
                }
            }
        }
        else
        {
            // start of tag
            NSArray *textComponents = [[text substringFromIndex:1] componentsSeparatedByString:@" "];
            tag = [textComponents objectAtIndex:0];
            //NSLog(@"start of tag: %@", tag);
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            for (NSUInteger i=1; i<[textComponents count]; i++)
            {
                NSArray *pair = [[textComponents objectAtIndex:i] componentsSeparatedByString:@"="];
                if ([pair count] > 0) {
                    NSString *key = [[pair objectAtIndex:0] lowercaseString];
                    
                    if ([pair count]>=2) {
                        // Trim " charactere
                        NSString *value = [[pair subarrayWithRange:NSMakeRange(1, [pair count] - 1)] componentsJoinedByString:@"="];
                        value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, 1)];
                        value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"" options:NSLiteralSearch range:NSMakeRange([value length]-1, 1)];
                        
                        // Trim ' characters
                        value = [value stringByReplacingOccurrencesOfString:@"\'" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, 1)];
                        value = [value stringByReplacingOccurrencesOfString:@"\'" withString:@"" options:NSLiteralSearch range:NSMakeRange([value length]-1, 1)];
                        
                        [attributes setObject:value forKey:key];
                    } else if ([pair count]==1) {
                        [attributes setObject:key forKey:key];
                    }
                }
            }
            QRHLabelComponent *component = [QRHLabelComponent componentWithString:nil tag:tag attributes:attributes];
            component.position = position;
            [components addObject:component];
        }
        last_position = position;
    }
    
    return [QRHLabelExtractedComponent rtLabelExtractComponentsWithTextComponent:components plainText:data];
}

@end
