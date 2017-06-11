//
//  CodingUtils.h
//  QLBase
//
//  Created by Odie Song on 14-10-3.
//  Copyright (c) 2014年 Odie Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodingUtils : NSObject

//对转译字符进行处理
+ (NSMutableString*)coverUnicodeToJsonFormat:(NSString*)source;

//DICTIONARY TO JSON
+ (NSData*)coverDictToJsonData:(id)dict;
+ (NSString*)coverDictToJsonString:(id)dict;

//转换时间的展现形式
+ (NSString *)getHHMMSS:(double)seconds;

//获取url中参数
+ (NSString*)parameterWithURL:(NSString*)url forKey:(NSString*)key;

@end

/**
 *  @author snowywu, 15-04-13
 *
 * DJB hash实现
 * 又名 time33
 *
 *  @param str <#str description#>
 *
 *  @return <#return value description#>
 */
static inline unsigned int DJBHash(const char *str);

static inline unsigned int DJBHash(const char *str)
{
    unsigned int hash = 2013;
    while (*str) hash += (hash << 5) + (*str++);
    return hash & 0x7fffffff;
}

/*!
 QLLoginManager
 QLMomentLoginMgr (Cookie)
 调用，其他全部 2013 
 hengzhuoliu 20150413
 */
static inline unsigned int DJBHash5381(const char *str);

static inline unsigned int DJBHash5381(const char *str)
{
    unsigned int hash = 5381;
    while (*str) hash += (hash << 5) + (*str++);
    return hash & 0x7fffffff;
}
