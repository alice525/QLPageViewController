/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define IFPGA_NAMESTRING                @"iFPGA"

#define IPHONE_2G_NAMESTRING            @"iPhone 2G"
#define IPHONE_3G_NAMESTRING            @"iPhone 3G"
#define IPHONE_3GS_NAMESTRING           @"iPhone 3GS"
#define IPHONE_4_NAMESTRING             @"iPhone 4"
#define IPHONE_4S_NAMESTRING            @"iPhone 4S"
#define IPHONE_5_NAMESTRING             @"iPhone 5"
#define IPHONE_5C_NAMESTRING            @"iPhone 5c"
#define IPHONE_5S_NAMESTRING            @"iPhone 5s"
#define IPHONE_6_NAMESTRING             @"iPhone 6"
#define IPHONE_6_PLUS_NAMESTRING        @"iPhone 6 plus"
#define IPHONE_6S_NAMESTRING            @"iPhone 6s"
#define IPHONE_6S_PLUS_NAMESTRING       @"iPhone 6s plus"
#define IPHONE_SE_NAMESTRING            @"iPhone SE"
#define IPHONE_7_NAMESTRING             @"iPhone 7"
#define IPHONE_7_PLUS_NAMESTRING        @"iPhone 7 plus"

#define IPHONE_UNKNOWN_NAMESTRING       @"Unknown iPhone"

#define IPOD_1G_NAMESTRING              @"iPod touch 1G"
#define IPOD_2G_NAMESTRING              @"iPod touch 2G"
#define IPOD_3G_NAMESTRING              @"iPod touch 3G"
#define IPOD_4G_NAMESTRING              @"iPod touch 4G"
#define IPOD_5G_NAMESTRING              @"iPod touch 5G"
#define IPOD_UNKNOWN_NAMESTRING         @"Unknown iPod"

#define IPAD_1G_NAMESTRING              @"iPad 1G"
#define IPAD_2_NAMESTRING               @"iPad 2"
#define IPAD_3_NAMESTRING               @"iPad 3"
#define IPAD_4_NAMESTRING               @"iPad 4"
#define IPAD_AIR_NAMESTRING             @"iPad Air"
#define IPAD_AIR2_NAMESTRING             @"iPad Air2"
#define IPAD_MINI_1G_NAMESTRING         @"iPad mini 1G"
#define IPAD_MINI_2_NAMESTRING         @"iPad mini 2"
#define IPAD_MINI_3_NAMESTRING         @"iPad mini 3"
#define IPAD_UNKNOWN_NAMESTRING         @"Unknown iPad"

#define APPLETV_2G_NAMESTRING           @"Apple TV 2G"
#define APPLETV_3G_NAMESTRING           @"Apple TV 3G"
#define APPLETV_4G_NAMESTRING           @"Apple TV 4G"
#define APPLETV_UNKNOWN_NAMESTRING      @"Unknown Apple TV"

#define IOS_FAMILY_UNKNOWN_DEVICE       @"Unknown iOS device"

#define SIMULATOR_NAMESTRING            @"iPhone Simulator"
#define SIMULATOR_IPHONE_NAMESTRING     @"iPhone Simulator"
#define SIMULATOR_IPAD_NAMESTRING       @"iPad Simulator"
#define SIMULATOR_APPLETV_NAMESTRING    @"Apple TV Simulator" // :)

// 判断是否高清屏
#ifndef isRetina
#define isRetina ([UIScreen instancesRespondToSelector:@selector(scale)] ? (2 == [[UIScreen mainScreen] scale]) : NO)
#endif

#ifndef SYSTEM_VERSION_MACRO
#define SYSTEM_VERSION_MACRO
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#endif

#ifndef QL_IS_IPAD
#define QL_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#endif

typedef NS_ENUM(NSUInteger, UIDevicePlatform) {
    UIDeviceUnknown,
    
    UIDeviceSimulator,
    UIDeviceSimulatoriPhone,
    UIDeviceSimulatoriPad,
    UIDeviceSimulatorAppleTV,
    
    UIDevice2GiPhone,
    UIDevice3GiPhone,
    UIDevice3GSiPhone,
    UIDevice4iPhone,
    UIDevice4SiPhone,
    UIDevice5iPhone,
    UIDevice5CiPhone,
    UIDevice5SiPhone,
    UIDevice6iPhone,
    UIDevice6PLUSiPhone,
    UIDevice6SiPhone,
    UIDevice6SPLUSiPhone,
    UIDeviceSEiPhone,
    UIDevice7iPhone,
    UIDevice7PLUSiPhone,
    
    UIDevice1GiPod,
    UIDevice2GiPod,
    UIDevice3GiPod,
    UIDevice4GiPod,
    UIDevice5GiPod,
    
    UIDevice1GiPad,
    UIDevice2iPad,
    UIDevice3iPad,
    UIDevice4iPad,
    UIDeviceiPadAir,
    UIDeviceiPadAir2,
    
    UIDevice1GiPadMini,
    UIDevice2iPadMini,
    UIDevice3iPadMini,
    
    UIDeviceAppleTV2,
    UIDeviceAppleTV3,
    UIDeviceAppleTV4,
    
    UIDeviceUnknowniPhone,
    UIDeviceUnknowniPod,
    UIDeviceUnknowniPad,
    UIDeviceUnknownAppleTV,
    UIDeviceIFPGA,
};

typedef NS_ENUM(NSUInteger, UIDeviceFamily) {
    UIDeviceFamilyiPhone,
    UIDeviceFamilyiPod,
    UIDeviceFamilyiPad,
    UIDeviceFamilyAppleTV,
    UIDeviceFamilyUnknown,
};

@interface UIDevice (Hardware)
- (NSString *) platform;
- (NSString *) hwmodel;
- (UIDevicePlatform) platformType;
- (NSString *) platformString;

- (NSUInteger) cpuFrequency;
- (NSUInteger) busFrequency;
- (NSUInteger) cpuCount;
- (NSString *) cpuType;
- (NSUInteger) totalMemory;
- (NSUInteger) userMemory;

- (NSNumber *) totalDiskSpace;
- (NSNumber *) freeDiskSpace;

- (NSString *) macAddress;

+ (NSString *) macAddress;

+ (NSString *)getGUID;

+ (BOOL) isRetinaDisplay;
- (UIDeviceFamily) deviceFamily;

+ (BOOL) IsARM64CPU;

+ (CGFloat)systemVersion;

+ (BOOL)isIOS93OrLatter;

+ (BOOL)isIOS10OrLatter;
+ (BOOL)isIOS901OrLatter;
+ (BOOL)isIOS9OrLatter;
+ (BOOL)isIOS802rLatter;
+ (BOOL)isIOS8OrLatter;
+ (BOOL)isIOS7OrLatter;
+ (BOOL)isIOS6OrLatter;

+ (BOOL)isIOS5OrEarlier;
+ (BOOL)isIOS6OrEarlier;
+ (BOOL)isIOS7OrEarlier;

+ (BOOL)isIOS6;
+ (BOOL)isIOS7;
+ (BOOL)isIOS8;
+ (BOOL)isIOS9;

//判断系统是否越狱，不使用Jailbreak命名,避免被苹果监测到
+ (BOOL)isJBOS;
@end
