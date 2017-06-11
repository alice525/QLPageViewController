//
//  QLWeakProxy.h
//  QLBaseCore
//
//  Created by jackhlzhang on 16/11/2.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QLWeakProxy : NSProxy
NS_ASSUME_NONNULL_BEGIN

@property (nullable, nonatomic, weak, readonly) id target;
- (instancetype)initWithTarget:(id)target;
+ (instancetype)proxyWithTarget:(id)target;

NS_ASSUME_NONNULL_END
@end
