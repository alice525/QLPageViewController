//
//  NSDictionary+SafeDictionary.h
//  live4iphone
//
//  Created by Snow Wu on 4/28/14.
//  modified by odie song on 8/30/14 区分SafeModel系列 和 ForKey系列
//  Copyright (c) 2014 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 用法：在原来的使用objectForKey之上重新组合两组更安全的方法
 SafeModel系列 保证返回的对象是有效对象，不会为空
 ForKey系列 只判断类型的合法性，无效会返回空
 */
@interface NSDictionary (SafeDictionary)

#pragma mark - 合法性判断的基础方法
- (Class)objectClassForKey:(id)aKey;

- (id)objectForKey:(id)aKey verifyClass:(Class)aClass;

- (BOOL)findForKey:(id)aKey;

#pragma mark - SafeModel系列
/*!
 默认值 @“”, 兼容object是number的情况，会转成对应的string
 */
- (NSString*)stringForKeySafeModel:(id)aKey;

/*!
默认值 [NSNumber numberWithInt:0], 兼容object是string的情况，会按整型来默认转换
 */
- (NSNumber*)numberForKeySafeModel:(id)aKey;

/*!
 默认值 [NSArray array]
 */
- (NSArray*)arrayForKeySafeModel:(id)aKey;

/*!
 默认值 [NSDictionary dictionary]
 */
- (NSDictionary*)dictionaryForKeySafeModel:(id)aKey;

/*!
 默认值 NO, 兼容number和string两种情况，会按整型来默认转换
 */
- (BOOL)boolForKeySafeModel:(id)aKey;

#pragma mark - ForKey系列

- (NSArray*)arrayForKey:(id)aKey;

- (NSDictionary*)dictionaryForKey:(id)aKey;

- (NSString*)stringForKey:(id)aKey;

- (NSNumber*)numberForKey:(id)aKey;

- (NSData*)dataForKey:(id)aKey;

- (NSDate*)dateForKey:(id)aKey;

- (NSURL*)urlForKey:(id)aKey;

#pragma mark - 替换系统方法

- (id)QLObjectForKey:(id)aKey;

- (void)QLRemoveObjectForKey:(id)aKey;
- (void)qlSetObject:(id)anObject forKey:(id <NSCopying>)aKey;

@end
