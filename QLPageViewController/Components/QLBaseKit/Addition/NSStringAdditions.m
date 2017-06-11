//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "NSStringAdditions.h"

// Core
#import "TTCorePreprocessorMacros.h"
#import "NSDataAdditions.h"
#import "TTBHtmlTagComponent.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
TT_FIX_CATEGORY_BUG(NSStringAdditions)

@implementation NSString (TTAdditions)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isWhitespaceAndNewlines {
  NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  for (NSInteger i = 0; i < self.length; ++i) {
    unichar c = [self characterAtIndex:i];
    if (![whitespace characterIsMember:c]) {
      return NO;
    }
  }
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Deprecated - https://github.com/facebook/three20/issues/367
 */
- (BOOL)isEmptyOrWhitespace {
  // A nil or NULL string is not the same as an empty string
  return 0 == self.length ||
         ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)stringByRemovingHTMLTags {
//  TTMarkupStripper* stripper = [[TTMarkupStripper alloc] init];
//  return [stripper parse:self];
    
    return [self alice_stringWithoutHtmlTags];
}

// 将字符串中的html标签去除   alicejhchen (2016-05-24)
- (NSString *)alice_stringWithoutHtmlTags {
//    NSScanner *scanner = nil;
//    NSString *text = nil;
//    
//    NSString *data = (NSString *)self;
//    
//    NSUInteger last_position = 0;
//    scanner = [NSScanner scannerWithString:data];
//    while (![scanner isAtEnd])
//    {
//        [scanner scanUpToString:@"<" intoString:NULL];
//        [scanner scanUpToString:@">" intoString:&text];
//        
//        NSString *delimiter = [NSString stringWithFormat:@"%@>", text];
//        NSUInteger position = [data rangeOfString:delimiter].location;
//        
//        if ( position!=NSNotFound)
//        {
//            data = [data stringByReplacingOccurrencesOfString:delimiter withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position+delimiter.length-last_position)];
//            
//            data = [data stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
//            data = [data stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
//        }
//        
//        last_position = position;
//    }
    
    NSScanner *scanner = nil;
    NSString *text = nil;
    NSString *tag = nil;
    
    NSString *data = [self copy];
    
    NSMutableArray *components = [NSMutableArray array];
    
    scanner = [NSScanner scannerWithString:data];
    while (![scanner isAtEnd])
    {
        [scanner scanUpToString:@"<" intoString:NULL];
        [scanner scanUpToString:@">" intoString:&text];
        
        NSString *delimiter = [NSString stringWithFormat:@"%@>", text];
        NSUInteger position = [data rangeOfString:delimiter].location;
        
        if ([text rangeOfString:@"</"].location==0)
        {
            // end of tag
            NSArray *textComponents = [[text substringFromIndex:2] componentsSeparatedByString:@" "];
            tag = [textComponents objectAtIndex:0];
            if (position!=NSNotFound)
            {
                NSInteger foundIdx = -1;
                
                for (int i = (int)components.count-1; i >= 0; i--)
                {
                    TTBHtmlTagComponent *component = components[i];
                    if ([component.tagLabel isEqualToString:tag])
                    {
                        foundIdx = i;
                        break;
                    }
                }
                
                // 找到与之对应的beginTag，将beginTag和endTag均替换成空字符串
                if (foundIdx >= 0) {
                    TTBHtmlTagComponent *component = components[foundIdx];
                    
                    data = [data stringByReplacingOccurrencesOfString:delimiter withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(position, delimiter.length)];
                    
                    data = [data stringByReplacingOccurrencesOfString:component.tagText withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(component.position, component.tagText.length)];
                    
                    //beginTag和endTag之间的html标签视为非html标签，因为没有endTag与之对应
                    for (int i = (int)components.count-1; i >= foundIdx; i--) {
                        [components removeObjectAtIndex:i];
                    }
                }
            }
        }
        else if ([text rangeOfString:@"/"].location == text.length-1)
        {
            // 闭合标签，如<img />
            if (position != NSNotFound) {
                data = [data stringByReplacingOccurrencesOfString:delimiter withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(position, delimiter.length)];
            }
        }
        else
        {
            // start of tag
            NSArray *textComponents = [[text substringFromIndex:1] componentsSeparatedByString:@" "];
            tag = [textComponents objectAtIndex:0];
            
            TTBHtmlTagComponent *component = [[TTBHtmlTagComponent alloc] init];
            component.tagLabel = [tag copy];
            component.tagText = [delimiter copy];
            component.position = position;
            
            [components addObject:component];
        }
    }
    
    return data;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Copied and pasted from http://www.mail-archive.com/cocoa-dev@lists.apple.com/msg28175.html
 * Deprecated
 */
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding {
  NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
  NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
  NSScanner* scanner = [[NSScanner alloc] initWithString:self];
  while (![scanner isAtEnd]) {
    NSString* pairString = nil;
    [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
    [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
    NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
    if (kvPair.count == 2) {
      NSString* key = [[kvPair objectAtIndex:0]
                       stringByReplacingPercentEscapesUsingEncoding:encoding];
      NSString* value = [[kvPair objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:encoding];
      [pairs setObject:value forKey:key];
    }
  }

  return [NSDictionary dictionaryWithDictionary:pairs];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)queryContentsUsingEncoding:(NSStringEncoding)encoding {
  NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
  NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
  NSScanner* scanner = [[NSScanner alloc] initWithString:self];
  while (![scanner isAtEnd]) {
    NSString* pairString = nil;
    [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
    [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
    NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
    if (kvPair.count == 1 || kvPair.count == 2) {
      NSString* key = [[kvPair objectAtIndex:0]
                       stringByReplacingPercentEscapesUsingEncoding:encoding];
      NSMutableArray* values = [pairs objectForKey:key];
      if (nil == values) {
        values = [NSMutableArray array];
        [pairs setObject:values forKey:key];
      }
      if (kvPair.count == 1) {
        [values addObject:[NSNull null]];

      } else if (kvPair.count == 2) {
        NSString* value = [[kvPair objectAtIndex:1]
                           stringByReplacingPercentEscapesUsingEncoding:encoding];
        [values addObject:value];
      }
    }
  }
  return [NSDictionary dictionaryWithDictionary:pairs];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)stringByAddingQueryDictionary:(NSDictionary*)query {
  NSMutableArray* pairs = [NSMutableArray array];
  for (NSString* key in [query keyEnumerator]) {
    NSString* value = [query objectForKey:key];
    value = [value stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
    value = [value stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    NSString* pair = [NSString stringWithFormat:@"%@=%@", key, value];
    [pairs addObject:pair];
  }

  NSString* params = [pairs componentsJoinedByString:@"&"];
  if ([self rangeOfString:@"?"].location == NSNotFound) {
    return [self stringByAppendingFormat:@"?%@", params];

  } else {
    return [self stringByAppendingFormat:@"&%@", params];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)stringByAddingURLEncodedQueryDictionary:(NSDictionary*)query {
  NSMutableDictionary* encodedQuery = [NSMutableDictionary dictionaryWithCapacity:[query count]];

  for (__strong NSString* key in [query keyEnumerator]) {
    NSParameterAssert([key respondsToSelector:@selector(urlEncoded)]);
    NSString* value = [query objectForKey:key];
    NSParameterAssert([value respondsToSelector:@selector(urlEncoded)]);
    value = [value urlEncoded];
    key = [key urlEncoded];
    [encodedQuery setValue:value forKey:key];
  }

  return [self stringByAddingQueryDictionary:encodedQuery];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)urlEncoded {
  CFStringRef cfUrlEncodedString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef)self,NULL,
                                            (CFStringRef)@"!#$%&'()*+,/:;=?@[]",
                                            kCFStringEncodingUTF8);

  NSString *urlEncoded = [NSString stringWithString:(__bridge NSString *)cfUrlEncodedString];
  CFRelease(cfUrlEncodedString);
  return urlEncoded;
}

-(NSString *)URLDecoded
{
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)self, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    return decodedString;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSComparisonResult)versionStringCompare:(NSString *)other {
  NSArray *oneComponents = [self componentsSeparatedByString:@"a"];
  NSArray *twoComponents = [other componentsSeparatedByString:@"a"];

  // The parts before the "a"
  NSString *oneMain = [oneComponents objectAtIndex:0];
  NSString *twoMain = [twoComponents objectAtIndex:0];

  // If main parts are different, return that result, regardless of alpha part
  NSComparisonResult mainDiff;
  if ((mainDiff = [oneMain compare:twoMain]) != NSOrderedSame) {
    return mainDiff;
  }

  // At this point the main parts are the same; just deal with alpha stuff
  // If one has an alpha part and the other doesn't, the one without is newer
  if ([oneComponents count] < [twoComponents count]) {
    return NSOrderedDescending;

  } else if ([oneComponents count] > [twoComponents count]) {
    return NSOrderedAscending;

  } else if ([oneComponents count] == 1) {
    // Neither has an alpha part, and we know the main parts are the same
    return NSOrderedSame;
  }

  // At this point the main parts are the same and both have alpha parts. Compare the alpha parts
  // numerically. If it's not a valid number (including empty string) it's treated as zero.
  NSNumber *oneAlpha = [NSNumber numberWithInt:[[oneComponents objectAtIndex:1] intValue]];
  NSNumber *twoAlpha = [NSNumber numberWithInt:[[twoComponents objectAtIndex:1] intValue]];
  return [oneAlpha compare:twoAlpha];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)md5Hash {
    //去掉QQ号登录状态以及QQ号切换对缓存的影响---weiliang--2013-8-29
    //去掉版本号变化对缓存的影响 odie
    NSString* noFilterURL = nil;
    NSString* orgString = [NSString stringWithString:self];
    NSArray* filterArray = [NSArray arrayWithObjects:@"&qq=", @"?qq=", @"&appver=", @"?appver=", @"&keytplid=",@"?keytplid=",@"&nettype=", nil];
    for (NSString* filterString in filterArray){
        NSRange rangeFilterStart = [orgString rangeOfString:filterString];
        NSRange rangeFilterEnd;
        if (rangeFilterStart.length > 0){
            NSRange start = {rangeFilterStart.location+rangeFilterStart.length, orgString.length - (rangeFilterStart.location+rangeFilterStart.length)};
            rangeFilterEnd = [orgString rangeOfString:@"&" options:NSCaseInsensitiveSearch range:start];
            if (rangeFilterEnd.length == 0){
                rangeFilterEnd.location = [orgString length];
            }
        }
        if(rangeFilterStart.location > 0 && rangeFilterStart.length > 0 && rangeFilterEnd.location > rangeFilterStart.location) {
            NSUInteger beforeLocation = ([filterString characterAtIndex:0] == '?') ? (rangeFilterStart.location + 1) : rangeFilterStart.location;
            NSUInteger afterLocation = ([filterString characterAtIndex:0] == '?') ? (rangeFilterEnd.location + 1) : rangeFilterEnd.location;
            if (afterLocation >= [orgString length]){
                beforeLocation -= 1;
                afterLocation = [orgString length];
            }
            NSString* beforeStr = [orgString substringToIndex:beforeLocation];
            NSString* afterStr = [orgString substringFromIndex:afterLocation];
            noFilterURL = [beforeStr stringByAppendingString:afterStr];
            orgString = noFilterURL;
        }
    }
    if (noFilterURL != nil){
        return [[noFilterURL dataUsingEncoding:NSUTF8StringEncoding] md5Hash];
    }
    
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5Hash];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)sha1Hash {
  return [[self dataUsingEncoding:NSUTF8StringEncoding] sha1Hash];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)stringByCleaningLinkTags {
    
    NSScanner *theScanner;
    NSString *text = nil;
    //NSString *linkPrefix = @"<a href";
    NSString *linkPrefix = @"<a ";
    NSString *suffix = @"/a>";
    NSString *target = self;
    
    theScanner = [NSScanner scannerWithString:self];
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        
        if ([theScanner scanUpToString:linkPrefix intoString:NULL]) {
            // find end of tag
            
            // 如果遇到类似<a href="http://v.qq.com/bar/10295" target="_blank" >，
            // text会停留在href="http://v.qq.com/bar/10295" target="_blank"的位置，
            // target="_blank"后面的空格会被漏掉，这是NSScanner的一个问题，需要规避，jiachunke(20160109)
            
            //if ([theScanner scanUpToString:@">" intoString:&text]) {
            if ([theScanner scanUpToString:suffix intoString:&text]) {
                // replace the found tag with a space
                
                //target = [target stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
                target = [target stringByReplacingOccurrencesOfString:text withString:@""];
            } else {
                
                break;
            }
            
        } else {
            
            break;
        }
    }
    
    if (self != target) {
        // 最后把suffix统一干掉，jiachunke(20160109)
        target = [target stringByReplacingOccurrencesOfString:suffix withString:@""];
    }
    
    return target;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)stringByRemovingHTMLTagsAddition {
    NSString *tempStr = [self stringByCleaningLinkTags];
    return [tempStr stringByRemovingHTMLTags];
}

@end
