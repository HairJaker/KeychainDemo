//
//  NSMutableDictionary+CTM_RequestDic.h
//  KeychainDemo
//
//  Created by yujie on 17/1/9.
//  Copyright © 2017年 yujie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (CTM_RequestDic)

+(NSMutableDictionary *)requestDictionaryWithToken:(NSString *)aToken;

@end
