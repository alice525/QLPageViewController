/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

// Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import  <mach/machine.h>
#import <SystemConfiguration/SystemConfiguration.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <ifaddrs.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "UIDevice-Hardware.h"

#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])

static NSString* g_local_system_version = nil;

const char* jb_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/etc/apt"
};

@implementation UIDevice (Hardware)

/*
 Platforms
 
 iFPGA ->        ??
 
 iPhone1,1 ->    iPhone 1G, M68
 iPhone1,2 ->    iPhone 3G, N82
 iPhone2,1 ->    iPhone 3GS, N88
 iPhone3,1 ->    iPhone 4/AT&T, N89
 iPhone3,2 ->    iPhone 4/Other Carrier?, ??
 iPhone3,3 ->    iPhone 4/Verizon, TBD
 iPhone4,1 ->    (iPhone 4S/GSM), TBD
 iPhone4,2 ->    (iPhone 4S/CDMA), TBD
 iPhone4,3 ->    (iPhone 4S/???)
 iPhone5,1 ->    iPhone Next Gen, TBD
 iPhone5,1 ->    iPhone Next Gen, TBD
 iPhone5,1 ->    iPhone Next Gen, TBD
 
 iPod1,1   ->    iPod touch 1G, N45
 iPod2,1   ->    iPod touch 2G, N72
 iPod2,2   ->    Unknown, ??
 iPod3,1   ->    iPod touch 3G, N18
 iPod4,1   ->    iPod touch 4G, N80
 
 // Thanks NSForge
 iPad1,1   ->    iPad 1G, WiFi and 3G, K48
 iPad2,1   ->    iPad 2G, WiFi, K93
 iPad2,2   ->    iPad 2G, GSM 3G, K94
 iPad2,3   ->    iPad 2G, CDMA 3G, K95
 iPad3,1   ->    (iPad 3G, WiFi)
 iPad3,2   ->    (iPad 3G, GSM)
 iPad3,3   ->    (iPad 3G, CDMA)
 iPad4,1   ->    (iPad 4G, WiFi)
 iPad4,2   ->    (iPad 4G, GSM)
 iPad4,3   ->    (iPad 4G, CDMA)
 
 AppleTV2,1 ->   AppleTV 2, K66
 AppleTV3,1 ->   AppleTV 3, ??
 
 i386, x86_64 -> iPhone Simulator
 */


#pragma mark sysctlbyname utils
- (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

- (NSString *) platform
{
    return [self getSysInfoByName:"hw.machine"];
}


// Thanks, Tom Harrington (Atomicbird)
- (NSString *) hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}

#pragma mark sysctl utils
- (NSUInteger) getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

- (NSUInteger) cpuFrequency
{
    return [self getSysInfo:HW_CPU_FREQ];
}

- (NSUInteger) busFrequency
{
    return [self getSysInfo:HW_BUS_FREQ];
}

- (NSUInteger) cpuCount
{
    return [self getSysInfo:HW_NCPU];
}

- (NSUInteger) totalMemory
{
    return [self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger) userMemory
{
    return [self getSysInfo:HW_USERMEM];
}

- (NSUInteger) maxSocketBufferSize
{
    return [self getSysInfo:KIPC_MAXSOCKBUF];
}

+(BOOL) IsARM64CPU
{
    if (sizeof(long) == 8){
        return YES;
    }
    return NO;
}

- (NSString *)cpuType {
    
    NSMutableString *cpu = [[NSMutableString alloc] init];
    size_t size;
    cpu_type_t type;
    cpu_subtype_t subtype;
    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);
    
    size = sizeof(subtype);
    sysctlbyname("hw.cpusubtype", &subtype, &size, NULL, 0);
    
    // values for cputype and cpusubtype defined in mach/machine.h
    if (type == CPU_TYPE_X86_64) {
        [cpu appendString:@"x86_64"];
    } else if (type == CPU_TYPE_X86) {
        [cpu appendString:@"x86"];
    } else if (type == CPU_TYPE_ARM) {
        [cpu appendString:@"ARM"];
        switch(subtype)
        {
            case CPU_SUBTYPE_ARM_V6:
                [cpu appendString:@"V6"];
                break;
            case CPU_SUBTYPE_ARM_V7:
            case CPU_SUBTYPE_ARM_V7F:
            case CPU_SUBTYPE_ARM_V7S:
            case CPU_SUBTYPE_ARM_V7K:
            case CPU_SUBTYPE_ARM_V7M:
            case CPU_SUBTYPE_ARM_V7EM:
                [cpu appendString:@"V7"];
                break;
            case CPU_SUBTYPE_ARM_V8:
                [cpu appendString:@"V8"];
                break;
            case CPU_SUBTYPE_ARM64_ALL:
            case CPU_SUBTYPE_ARM64_V8:
                [cpu appendString:@"64"];
                break;
        }
    }else if (type == CPU_TYPE_ARM64) {
        [cpu appendString:@"ARM64"];
    }
    
    return cpu;
}

#pragma mark ios version

+ (CGFloat)systemVersion
{
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    return [g_local_system_version floatValue] ;
    
}

+ (BOOL)isIOS93OrLatter
{
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    float systemVersion = [g_local_system_version floatValue];
    
    if( systemVersion >= 9.3 || [g_local_system_version isEqualToString:@"9.3.0"])
        return YES;
    
    return NO;
    
}
+ (BOOL)isIOS901OrLatter
{
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    float systemVersion = [g_local_system_version floatValue];
    
    if( systemVersion > 9 || [g_local_system_version isEqualToString:@"9.0.1"])
        return YES;
    
    return NO;
    
}

+ (BOOL)isIOS10OrLatter {
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    if([g_local_system_version floatValue] >= 10)
        return YES;
    
    return NO;
}



+ (BOOL)isIOS9OrLatter {
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    if([g_local_system_version floatValue] >= 9)
        return YES;
    
    return NO;
}

+ (BOOL)isIOS802rLatter {
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    if([g_local_system_version floatValue] >= 8.02)
        return YES;
    
    return NO;
}


+ (BOOL)isIOS8OrLatter {
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    if([g_local_system_version floatValue] >= 8)
        return YES;
    
    return NO;
}

+ (BOOL)isIOS7OrLatter {
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    if([g_local_system_version floatValue] >= 7)
        return YES;
    
    return NO;
}

+ (BOOL)isIOS6OrLatter {
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    if( [g_local_system_version floatValue] >= 6 )
        return YES;
    
    return NO;
}

+ (BOOL)isIOS6 {
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    if( [g_local_system_version floatValue] < 7 && [g_local_system_version floatValue] >= 6)
        return YES;
    
    return NO;
}

+ (BOOL)isIOS5OrEarlier {
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    if( [g_local_system_version floatValue] < 6 )
        return YES;
    
    return NO;
}

+ (BOOL)isIOS6OrEarlier {
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    if( [g_local_system_version floatValue] < 7 )
        return YES;
    
    return NO;
}

+ (BOOL)isIOS7OrEarlier {
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    if( [g_local_system_version floatValue] < 8 )
        return YES;
    
    return NO;
}

+ (BOOL)isIOS7
{
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    if( [g_local_system_version floatValue] < 8 && [g_local_system_version floatValue] >= 7)
        return YES;
    
    return NO;
    
}

+ (BOOL)isIOS8
{
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    if( [g_local_system_version floatValue] < 9 && [g_local_system_version floatValue] >= 8)
        return YES;
    
    return NO;
    
}

+ (BOOL)isIOS9
{
    if (g_local_system_version == nil) {
        g_local_system_version = [[UIDevice currentDevice] systemVersion];
    }
    
    if( [g_local_system_version floatValue] < 10 && [g_local_system_version floatValue] >= 9)
        return YES;
    
    return NO;
    
}

#pragma mark file system -- Thanks Joachim Bean!

/*
 extern NSString *NSFileSystemSize;
 extern NSString *NSFileSystemFreeSize;
 extern NSString *NSFileSystemNodes;
 extern NSString *NSFileSystemFreeNodes;
 extern NSString *NSFileSystemNumber;
 */

- (NSNumber *) totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

- (NSNumber *) freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

#pragma mark platform type and name utils
- (UIDevicePlatform) platformType
{
    NSString *platform = [self platform];
    
    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return UIDevice2GiPhone;
    if ([platform isEqualToString:@"iPhone1,2"])    return UIDevice3GiPhone;
    if ([platform hasPrefix:@"iPhone2"])            return UIDevice3GSiPhone;
    if ([platform hasPrefix:@"iPhone3"])            return UIDevice4iPhone;
    if ([platform hasPrefix:@"iPhone4"])            return UIDevice4SiPhone;
    if ([platform isEqualToString:@"iPhone5,1"]
        || [platform isEqualToString:@"iPhone5,2"]) return UIDevice5iPhone;
    if ([platform isEqualToString:@"iPhone5,3"]
        || [platform isEqualToString:@"iPhone5,4"]) return UIDevice5CiPhone;
    if ([platform hasPrefix:@"iPhone6"])            return UIDevice5SiPhone;
    if ([platform isEqualToString:@"iPhone7,2"])    return UIDevice6iPhone;
    if ([platform isEqualToString:@"iPhone7,1"])    return UIDevice6PLUSiPhone;
    if ([platform isEqualToString:@"iPhone8,1"])    return UIDevice6SiPhone;
    if ([platform isEqualToString:@"iPhone8,2"])    return UIDevice6SPLUSiPhone;
    if ([platform isEqualToString:@"iPhone8,4"])    return UIDeviceSEiPhone;
    if ([platform isEqualToString:@"iPhone9,2"])    return UIDevice7PLUSiPhone;
    if ([platform isEqualToString:@"iPhone9,3"])    return UIDevice7iPhone;
    
    // iPod
    if ([platform hasPrefix:@"iPod1"])              return UIDevice1GiPod;
    if ([platform hasPrefix:@"iPod2"])              return UIDevice2GiPod;
    if ([platform hasPrefix:@"iPod3"])              return UIDevice3GiPod;
    if ([platform hasPrefix:@"iPod4"])              return UIDevice4GiPod;
    if ([platform hasPrefix:@"iPod5"])              return UIDevice5GiPod;
    
    // iPad
    if ([platform hasPrefix:@"iPad1"])              return UIDevice1GiPad;
    if ([platform isEqualToString:@"iPad2,1"]
        || [platform isEqualToString:@"iPad2,2"]
        || [platform isEqualToString:@"iPad2,3"]
        || [platform isEqualToString:@"iPad2,4"])   return UIDevice2iPad;
    if ([platform isEqualToString:@"iPad3,1"]
        || [platform isEqualToString:@"iPad3,2"]
        || [platform isEqualToString:@"iPad3,3"])   return UIDevice3iPad;
    if ([platform isEqualToString:@"iPad3,4"]
        || [platform isEqualToString:@"iPad3,5"]
        || [platform isEqualToString:@"iPad3,6"])   return UIDevice4iPad;
    if ([platform isEqualToString:@"iPad4,1"]
        || [platform isEqualToString:@"iPad4,2"]
        || [platform isEqualToString:@"iPad4,3"])   return UIDeviceiPadAir;
    if ([platform isEqualToString:@"iPad5,3"])    return UIDeviceiPadAir2;
    if ([platform isEqualToString:@"iPad5,4"])    return UIDeviceiPadAir2;
    
    // iPad mini
    if ([platform isEqualToString:@"iPad2,5"])    return UIDevice1GiPadMini;
    if ([platform isEqualToString:@"iPad2,6"])    return UIDevice1GiPadMini;
    if ([platform isEqualToString:@"iPad2,7"])    return UIDevice1GiPadMini;
    if ([platform isEqualToString:@"iPad4,4"])    return UIDevice2iPadMini;
    if ([platform isEqualToString:@"iPad4,5"])    return UIDevice2iPadMini;
    if ([platform isEqualToString:@"iPad4,6"])    return UIDevice2iPadMini;
    if ([platform isEqualToString:@"iPad4,7"])    return UIDevice3iPadMini;
    if ([platform isEqualToString:@"iPad4,8"])    return UIDevice3iPadMini;
    if ([platform isEqualToString:@"iPad4,9"])    return UIDevice3iPadMini;
    
    // Apple TV
    if ([platform hasPrefix:@"AppleTV2"])           return UIDeviceAppleTV2;
    if ([platform hasPrefix:@"AppleTV3"])           return UIDeviceAppleTV3;
    if ([platform isEqualToString:@"AppleTV3,2"])    return UIDeviceAppleTV4;
    
    if ([platform hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
    if ([platform hasPrefix:@"AppleTV"])            return UIDeviceUnknownAppleTV;
    
    // Simulator thanks Jordan Breeding
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? UIDeviceSimulatoriPhone : UIDeviceSimulatoriPad;
    }
    
    return UIDeviceUnknown;
}

- (NSString *) platformString
{
    switch ([self platformType])
    {
        case UIDevice2GiPhone: return IPHONE_2G_NAMESTRING;
        case UIDevice3GiPhone: return IPHONE_3G_NAMESTRING;
        case UIDevice3GSiPhone: return IPHONE_3GS_NAMESTRING;
        case UIDevice4iPhone: return IPHONE_4_NAMESTRING;
        case UIDevice4SiPhone: return IPHONE_4S_NAMESTRING;
        case UIDevice5iPhone: return IPHONE_5_NAMESTRING;
        case UIDevice5CiPhone: return IPHONE_5C_NAMESTRING;
        case UIDevice5SiPhone: return IPHONE_5S_NAMESTRING;
        case UIDevice6iPhone: return IPHONE_6_NAMESTRING;
        case UIDevice6PLUSiPhone: return IPHONE_6_PLUS_NAMESTRING;
            
        case UIDevice6SiPhone: return IPHONE_6S_NAMESTRING;
        case UIDevice6SPLUSiPhone: return IPHONE_6S_PLUS_NAMESTRING;
        case UIDeviceSEiPhone: return IPHONE_SE_NAMESTRING;
        case UIDevice7PLUSiPhone: return IPHONE_7_PLUS_NAMESTRING;
        case UIDevice7iPhone: return IPHONE_7_NAMESTRING;
            
        case UIDeviceUnknowniPhone: return IPHONE_UNKNOWN_NAMESTRING;
            
        case UIDevice1GiPod: return IPOD_1G_NAMESTRING;
        case UIDevice2GiPod: return IPOD_2G_NAMESTRING;
        case UIDevice3GiPod: return IPOD_3G_NAMESTRING;
        case UIDevice4GiPod: return IPOD_4G_NAMESTRING;
        case UIDevice5GiPod: return IPOD_5G_NAMESTRING;
        case UIDeviceUnknowniPod: return IPOD_UNKNOWN_NAMESTRING;
            
        case UIDevice1GiPad : return IPAD_1G_NAMESTRING;
        case UIDevice2iPad : return IPAD_2_NAMESTRING;
        case UIDevice3iPad : return IPAD_3_NAMESTRING;
        case UIDevice4iPad : return IPAD_4_NAMESTRING;
        case UIDeviceiPadAir : return IPAD_AIR_NAMESTRING;
        case UIDeviceiPadAir2: return IPAD_AIR2_NAMESTRING;
        case UIDevice1GiPadMini : return IPAD_MINI_1G_NAMESTRING;
        case UIDevice2iPadMini : return IPAD_MINI_2_NAMESTRING;
        case UIDevice3iPadMini: return IPAD_MINI_3_NAMESTRING;
        case UIDeviceUnknowniPad : return IPAD_UNKNOWN_NAMESTRING;
            
        case UIDeviceAppleTV2 : return APPLETV_2G_NAMESTRING;
        case UIDeviceAppleTV3 : return APPLETV_3G_NAMESTRING;
        case UIDeviceAppleTV4 : return APPLETV_4G_NAMESTRING;
        case UIDeviceUnknownAppleTV: return APPLETV_UNKNOWN_NAMESTRING;
            
        case UIDeviceSimulator: return SIMULATOR_NAMESTRING;
        case UIDeviceSimulatoriPhone: return SIMULATOR_IPHONE_NAMESTRING;
        case UIDeviceSimulatoriPad: return SIMULATOR_IPAD_NAMESTRING;
        case UIDeviceSimulatorAppleTV: return SIMULATOR_APPLETV_NAMESTRING;
            
        case UIDeviceIFPGA: return IFPGA_NAMESTRING;
            
        default: return IOS_FAMILY_UNKNOWN_DEVICE;
    }
}

+ (BOOL) isRetinaDisplay
{
    if ([UIScreen instancesRespondToSelector:@selector(scale)]){
        return ([UIScreen mainScreen].scale >= 2.0f);
    }
    return NO;
}

- (UIDeviceFamily) deviceFamily
{
    NSString *platform = [self platform];
    if ([platform hasPrefix:@"iPhone"]) return UIDeviceFamilyiPhone;
    if ([platform hasPrefix:@"iPod"]) return UIDeviceFamilyiPod;
    if ([platform hasPrefix:@"iPad"]) return UIDeviceFamilyiPad;
    if ([platform hasPrefix:@"AppleTV"]) return UIDeviceFamilyAppleTV;
    
    return UIDeviceFamilyUnknown;
}

#pragma mark MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *) macAddress
{
    return [UIDevice macAddress];
}

+ (NSString *) macAddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    return outstring;
}

+ (NSString *)getGUID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults stringForKey:@"guid"]) {
        return [userDefaults stringForKey:@"guid"];
    }
    else {
        CFUUIDRef uuidObj = CFUUIDCreate(nil);// create a new UUID
        // get the string representation of the UUID
        NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
        CFRelease(uuidObj);
        [userDefaults setObject:uuidString forKey:@"guid"];
        [userDefaults synchronize];
        
        //return [[uuidString autorelease] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        return uuidString;
    }
}

// Illicit Bluetooth check -- cannot be used in App Store
/*
 Class  btclass = NSClassFromString(@"GKBluetoothSupport");
 if ([btclass respondsToSelector:@selector(bluetoothStatus)])
 {
 printf("BTStatus %d\n", ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0);
 bluetooth = ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0;
 printf("Bluetooth %s enabled\n", bluetooth ? "is" : "isn't");
 }
 */

#pragma mark - JBOS
+ (BOOL)isFoundJBPath
{
    for (int i=0; i<ARRAY_SIZE(jb_tool_pathes); i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jb_tool_pathes[i]]]) {
            NSLog(@"The device is jail broken!");
            return YES;
        }
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}

+ (BOOL)isCanCallCydia
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        NSLog(@"The device is jail broken!");
        return YES;
    }
    NSLog(@"The device is NOT jail broken!");
    return NO;
}

#define USER_APP_PATH                 @"/User/Applications/"
#define USER_APP_PATH_IOS8            @"/User/Containers/Bundle/Application/"

+ (BOOL)isCanAccessUserAppPath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH]) {
        NSLog(@"The device is jail broken!");
        //NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:USER_APP_PATH error:nil];
        //NSLog(@"applist = %@", applist);
        return YES;
    }
    if ([UIDevice isIOS8OrLatter]){
        if ([[NSFileManager defaultManager] fileExistsAtPath:USER_APP_PATH_IOS8]) {
            NSLog(@"The device is jail broken!");
            //NSArray *applist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:USER_APP_PATH error:nil];
            //NSLog(@"applist = %@", applist);
            return YES;
        }
    }

    NSLog(@"The device is NOT jail broken!");
    return NO;
}


+ (BOOL)isJBOS
{
#ifdef DEBUG
    //    return YES;
#if (TARGET_IPHONE_SIMULATOR)

    // 在模拟器的情况下
    //        return YES;
#else

    // 在真机情况下

#endif

#endif
    if ([UIDevice isCanAccessUserAppPath] && [UIDevice isCanCallCydia] && [UIDevice isFoundJBPath]){
        return YES;
    }
    return NO;
}
@end
