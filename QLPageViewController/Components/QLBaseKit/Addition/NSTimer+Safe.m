//
//  NSTimer+Safe.m
//  QLBaseCore
//
//  Created by Norcy on 16/8/5.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "NSTimer+Safe.h"
#import "QLWeakProxy.h"

@implementation NSTimer(QLSafeTimer)
+ (NSTimer *)ql_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                          block:(void(^)())block
                                        repeats:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(ql_blockHandle:)
                                       userInfo:[block copy]    //记得使用 copy
                                        repeats:repeats];
}

+ (void)ql_blockHandle:(NSTimer *)timer
{
    void (^block)() = timer.userInfo;
    if (block)
    {
        block();
    }
}

+ (NSTimer *)safeScheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo
{
    return [self scheduledTimerWithTimeInterval:ti target:[QLWeakProxy proxyWithTarget:aTarget] selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

+ (NSTimer *)safeTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo
{
    return [self timerWithTimeInterval:ti target:[QLWeakProxy proxyWithTarget:aTarget] selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

@end
