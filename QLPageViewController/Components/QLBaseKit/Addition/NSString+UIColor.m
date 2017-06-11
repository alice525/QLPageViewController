//
//  NSString+UIColor.m
//  QLBaseKit
//
//  Created by Norcy on 2017/5/11.
//  Copyright © 2017年 Norcy. All rights reserved.
//

#import "NSString+UIColor.h"

@implementation NSString (UIColor)
- (UIColor *)toUIColor
{
	/*是否需要先对NSString的格式是否符合UIColor的表示方法进行判断？有没有网络传输异常导致字符接收错误的情况？zhngliao（2015/10/10）*/
	if (!self.length)
	{
		return nil;
	}

	unsigned int c = 0; //基本类型的局部变量声明的时候最好初始化一下 否则在不同的环境下默认值可能各不相同 Norcy(20160509)
	bool isRGBA = NO;
	if ([self characterAtIndex:0] == '#')
	{
		isRGBA = (self.length == 9);
		[[NSScanner scannerWithString:[self substringFromIndex:1]] scanHexInt:&c];
	}
	else
	{
		isRGBA = (self.length == 8);
		[[NSScanner scannerWithString:self] scanHexInt:&c];
	}

	//这里兼容一下android那边的ARGB （-。-）！ Norcy(20150824)
	if (isRGBA)
	{
		return [UIColor colorWithRed:((c & 0xff0000) >> 16) / 255.0 green:((c & 0xff00) >> 8) / 255.0 blue:(c & 0xff) / 255.0 alpha:((c & 0xff000000) >> 24) / 255.0];
	}
	else
	{
		return [UIColor colorWithRed:((c & 0xff0000) >> 16) / 255.0 green:((c & 0xff00) >> 8) / 255.0 blue:(c & 0xff) / 255.0 alpha:1.0];
	}
}
@end
