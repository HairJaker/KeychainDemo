//
//  NSMutableDictionary+CTM_RequestDic.m
//  KeychainDemo
//
//  Created by yujie on 17/1/9.
//  Copyright © 2017年 yujie. All rights reserved.
//

#import "NSMutableDictionary+CTM_RequestDic.h"
#import "UIDevice+CTM_DeviceModel.h"
#import "CTM_Keychain.h"

#define kVersion

NSString * const KEY_UDID = @"com.jingcaimao.KeychainDemo";

@implementation NSMutableDictionary (CTM_RequestDic)

+(NSMutableDictionary *)requestDictionaryWithToken:(NSString *)aToken{
    
    NSMutableDictionary * requestDic = [[NSMutableDictionary alloc]init];
    NSString  * buildVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    [requestDic setValue:aToken forKey:@"requestToken"];
    [requestDic setValue:[self getUUID] forKey:@"uuid"];
    [requestDic setValue:buildVersion forKey:@"buildVersion"];
    [requestDic setValue:[UIDevice deviceName] forKey:@"platform"];
    
    return requestDic;
}

+(NSString *)getUUID{
    
    NSString * udid = [CTM_Keychain load:KEY_UDID];
    
    NSData* data = [[CTM_Keychain uuid] dataUsingEncoding:NSUTF8StringEncoding];
    
    if (udid == nil || udid.length == 0) {
        [CTM_Keychain save:KEY_UDID data:data];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[CTM_Keychain load:KEY_UDID] forKey:@"UDID"];
    
    return [CTM_Keychain load:KEY_UDID];
    
}

@end
