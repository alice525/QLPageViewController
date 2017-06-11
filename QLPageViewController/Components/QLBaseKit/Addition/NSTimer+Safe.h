//
//  NSTimer+Safe.h
//  QLBaseCore
//
//  Created by Norcy on 16/8/5.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSTimer(QLSafeTimer)
+ (NSTimer *)ql_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)())block repeats:(BOOL)repeats;


+ (NSTimer *)safeScheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

+ (NSTimer *)safeTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

@end
NS_ASSUME_NONNULL_END