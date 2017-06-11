//
//  NSDictionary+SafeDictionary.m
//  live4iphone
//
//  Created by Snow Wu on 4/28/14.
//  Copyright (c) 2014 Tencent. All rights reserved.
//

#import "NSDictionary+SafeDictionary.h"

@implementation NSDictionary (SafeDictionary)

#pragma mark - 合法性判断的基础方法

- (Class)objectClassForKey:(id)aKey
{
    if (nil == aKey){
        return nil;
    }
    id resultObject = [self objectForKey:aKey];
    if (nil != resultObject) {
        @try {
            return [resultObject class];
        }
        @catch (NSException *exception) {
            NSLog(@"NSException info %@",exception);
            return nil;
        }
    }
    return nil;
}

- (id)objectForKey:(id)aKey verifyClass:(Class)aClass
{
    if (nil == aKey){
        return nil;
    }
    id resultObject = [self objectForKey:aKey];
    if (nil != resultObject) {
        @try {
            if ([resultObject isKindOfClass:aClass]){
                return resultObject;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"NSException info %@",exception);
            return nil;
        }
    }
    return nil;
}

- (BOOL)findForKey:(id)aKey
{
    if (nil == aKey){
        return NO;
    }
    id resultObject = [self objectForKey:aKey];
    if (nil == resultObject){
        return NO;
    }
    return YES;
}

#pragma mark -  SafeModel系列

- (NSArray*)arrayForKeySafeModel:(id)aKey
{
    NSArray* resultObject = [self arrayForKey:aKey];
    if (nil == resultObject){
        return [NSArray array];
    }
    return resultObject;
}

- (NSDictionary*)dictionaryForKeySafeModel:(id)aKey
{
    NSDictionary* resultObject = [self dictionaryForKey:aKey];
    if (nil == resultObject){
        return [NSDictionary dictionary];
    }
    return resultObject;
}

- (NSString*)stringForKeySafeModel:(id)aKey
{
    NSString* resultObject = [self stringForKey:aKey];
    if (nil == resultObject){
        NSNumber* num = [self numberForKey:aKey];
        if (nil != num){
            resultObject = [NSString stringWithFormat:@"%@", num];
            return resultObject;
        }
        return @"";
    }
    return resultObject;
}

- (NSNumber*)numberForKeySafeModel:(id)aKey
{
    NSNumber* resultObject = [self numberForKey:aKey];
    if (nil == resultObject){
        NSString* str = [self stringForKey:aKey];
        if (nil != str){
            NSNumber* num = [NSNumber numberWithInt:[str intValue]];
            return num;
        }
        return [NSNumber numberWithInt:0];
    }
    return resultObject;
}

- (BOOL)boolForKeySafeModel:(id)aKey
{
    NSNumber* num = [self numberForKeySafeModel:aKey];
    if (nil != num){
        return [num boolValue];
    }
    return NO;
}

#pragma mark - ForKey系列

- (NSArray*)arrayForKey:(id)aKey
{
    NSArray* resultObject = [self objectForKey:aKey verifyClass:[NSArray class]];
    return resultObject;
}

- (NSDictionary*)dictionaryForKey:(id)aKey
{
    NSDictionary* resultObject = [self objectForKey:aKey verifyClass:[NSDictionary class]];
    return resultObject;
}

- (NSString*)stringForKey:(id)aKey
{
    NSString* resultObject = [self objectForKey:aKey verifyClass:[NSString class]];
    return resultObject;
}

- (NSNumber*)numberForKey:(id)aKey
{
    NSNumber* resultObject = [self objectForKey:aKey verifyClass:[NSNumber class]];
    return resultObject;
}

- (NSData*)dataForKey:(id)aKey
{
    NSData* resultObject = [self objectForKey:aKey verifyClass:[NSData class]];
    return resultObject;
}

- (NSDate*)dateForKey:(id)aKey
{
    NSDate* resultObject = [self objectForKey:aKey verifyClass:[NSDate class]];
    return resultObject;
}

- (NSURL*)urlForKey:(id)aKey
{
    NSURL* resultObject = [self objectForKey:aKey verifyClass:[NSURL class]];
    return resultObject;
}

#pragma mark - 替换系统方法

- (id)QLObjectForKey:(id)aKey
{
    if (nil == aKey){
        return nil;
    }
    id ret = nil;
    @try {
        ret = [self QLObjectForKey:aKey];
    }
    @catch (NSException *exception) {
        NSLog(@"objectForKey excption=%@",exception);
    }
    @catch (...) {
        
    }
    return ret;
}

- (void)QLRemoveObjectForKey:(id)aKey
{
    if (nil == aKey){
#ifdef DEBUG
        @throw NSInvalidArgumentException;
#endif
        return;
    }
    @try {
        [self QLRemoveObjectForKey:aKey];
    }
    @catch (NSException *exception) {
        NSLog(@"removeObjectForKey excption=%@",exception);
    }
    @catch (...) {
        
    }
}

- (void)qlSetObject:(id)anObject forKey:(id <NSCopying>)aKey
{
    if (nil != aKey && nil == anObject) {//modified by zhangliao(2016/05/23 V4.8.6)
        [self QLRemoveObjectForKey:aKey];
        return;
        
    }else if (nil == aKey || nil == anObject){
#ifdef DEBUG
        @throw NSInvalidArgumentException;
#endif
        return;
    }
    @try {
        [self qlSetObject:anObject forKey:aKey];
    }
    @catch (NSException *exception) {
        NSLog(@"setObject excption=%@",exception);
    }
    @catch (...) {
        
    }
}

- (void)qlSetObject:(id)anObject forKeyedSubscript:(id <NSCopying>)aKey
{
    if (nil != aKey && nil == anObject) {//modified by zhangliao(2016/05/23 V4.8.6)
        [self QLRemoveObjectForKey:aKey];
        return;
        
    }else if (nil == aKey || nil == anObject){
#ifdef DEBUG
        @throw NSInvalidArgumentException;
#endif
        return;
    }
    @try {
        [self qlSetObject:anObject forKeyedSubscript:aKey];
    }
    @catch (NSException *exception) {
        NSLog(@"qlSetObject forKeyedSubscript excption=%@",exception);
    }
    @catch (...) {
        
    }
}
@end
