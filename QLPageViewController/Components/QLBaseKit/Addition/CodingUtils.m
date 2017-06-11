//
//  CodingUtils.m
//  QLBase
//
//  Created by Odie Song on 14-10-3.
//  Copyright (c) 2014年 Odie Song. All rights reserved.
//

#import "CodingUtils.h"
//#import "QLBaseCore.h"

@implementation CodingUtils

+ (NSMutableString*)coverUnicodeToJsonFormat:(NSString*)source
{
    NSMutableString* dest = [NSMutableString stringWithString:source];
    [dest replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, [dest length])];
    [dest replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, [dest length])];
    return dest;
}

+ (NSData*)coverDictToJsonData:(id)dict
{
    if ( !dict ) {
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if ([jsonData length] > 0 && error == nil){
        NSLog(@"Successfully serialized the dictionary into data.");
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"JSON String = %@", jsonString);
    }
    else if ([jsonData length] == 0 &&
             error == nil){
        NSLog(@"No data was returned after serialization.");
        return nil;
    }
    else if (error != nil){
        NSLog(@"An error happened = %@", error);
        return nil;
    }
    return jsonData;
}

+ (NSString*)coverDictToJsonString:(id)dict
{
    if ( !dict ) {
        return nil;
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if ([jsonData length] > 0 && error == nil){
        NSLog(@"Successfully serialized the dictionary into data.");
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"JSON String = %@", jsonString);
        return jsonString;
    }
    else if ([jsonData length] == 0 &&
             error == nil){
        NSLog(@"No data was returned after serialization.");
        return nil;
    }
    else if (error != nil){
        NSLog(@"An error happened = %@", error);
        return nil;
    }
    return nil;
}

//转换时间的展现形式
+ (NSString *)getHHMMSS:(double)seconds
{
    //5.2改成四舍五入 elonliu 20161026
//    int intSeconds = NSInteger2Int(seconds);
    int intSeconds = round(seconds);
    
    int h=0,s=0,m=0;
    
    s = intSeconds%60;
    
    if (intSeconds >= 60) {
        
        m = (intSeconds/60)%60;
        
        if (intSeconds/60 >= 60) {
            
            h = (intSeconds/60)/60;
            
        }
    }
    
    if (isnan(s) || isinf(s)) {
        s = 0;
    }
    if (isnan(m) || isinf(m)) {
        m = 0;
    }
    if (isnan(h) || isinf(h)) {
        h = 0;
    }
    
    if ( h > 0 ) {
        return [NSString stringWithFormat:@"%d:%02d:%02d",h,m,s];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d",m,s];
    }
}

+ (NSString *)getNumberFromEpisodeTitle:(NSString *)title
{
    NSString *number = title;
    if([number rangeOfString:@"第"].length > 0)
    {
        NSRange tmpRange = [number rangeOfString:@"第"];
        // 去掉第字
        number = [number substringFromIndex:tmpRange.location + tmpRange.length];
        
        if ([number rangeOfString:@"集"].length > 0 ) {
            number = [number substringToIndex:[number rangeOfString:@"集"].location];
        }
        else if ([number rangeOfString:@"画"].length > 0 ) {
            number = [number substringToIndex:[number rangeOfString:@"画"].location];
        }
        else if ([number rangeOfString:@"话"].length > 0 ) {
            number = [number substringToIndex:[number rangeOfString:@"话"].location];
        }
    }
    return [NSString stringWithFormat:@"%02d", [number intValue]];
}

+ (NSString*)parameterWithURL:(NSString*)url forKey:(NSString*)key
{
    if (url == nil || key == nil) {
        return nil;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:url];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
    [scanner scanUpToString:@"?" intoString:nil];
    
    NSString *tmpValue;
    while ([scanner scanUpToString:@"&" intoString:&tmpValue])
    {
        NSArray *components = [tmpValue componentsSeparatedByString:@"="];
        
        if (components.count >= 2)
        {
            if ([[components[0] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding] isEqualToString:key]) {
                NSString *value = [components[1] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
                return value;
            }
        }
    }
    
    return nil;
}

@end
