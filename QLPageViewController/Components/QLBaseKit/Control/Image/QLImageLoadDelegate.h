//
//  QLImageLoadDelegate.h
//  live4iphone
//
//  Created by chen selwin on 13-12-12.
//  Copyright (c) 2013年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QLImageLoadDelegate <NSObject>

@optional
- (void)didStartLoadImageForURL:(NSString*)imageURL;

- (void)didLoadImage:(UIImage*)image forURL:(NSString*)imageURL;

- (void)didLoadImage:(UIImage*)image forURL:(NSString*)imageURL imageView:(id)imageView;

- (void)didFailLoadWithError:(NSError*)error forURL:(NSString*)imageURL;

// 490 新增一个接口调用，通知 delegate 加载到的图片是 gif 图片
- (void)didFinishDownloadImage:(NSString *)imageUrl withIsGif:(BOOL)isGif;

// 550 新增接口，支持gif图两种展示样式：同步展示首帧静态图（NO）和 异步展示动态图（YES）
- (BOOL)shouldAsyncLoadAnimatedImageForGif;
@end
