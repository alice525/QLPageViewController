//
//  QNBBaseImageView.h
//  QLBaseKit
//
//  Created by Norcy on 2017/5/8.
//  Copyright © 2017年 Norcy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QLImageLoadDelegate.h"

@interface QNBBaseImageView : UIImageView<QLImageLoadDelegate>
{
    NSString *_urlPath;
}

@property (nonatomic, copy) NSString *urlPath; //图片路径
@property (nonatomic, weak) id<QLImageLoadDelegate> imDelegate;

// 设置图片url并指定保存路径 Norcy(20160808) v5.0.1
- (void)setUrlPath:(NSString *)urlPath filePath:(NSString *)filePath;

@end
