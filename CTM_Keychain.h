//
//  CTM_Keychain.h
//  KeychainDemo
//
//  Created by yujie on 17/1/9.
//  Copyright © 2017年 yujie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTM_Keychain : NSObject

+(void)save:(NSString *)service data:(id)data;

+(id)load:(NSString *)service;

+(NSString*)uuid;

@end
