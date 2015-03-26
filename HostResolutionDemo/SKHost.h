//
//  SKHost.h
//  HostResolutionDemo
//
//  Created by ChenHao on 15/3/26.
//  Copyright (c) 2015年 ChenHao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LCHostCompletionBlock) (BOOL completion, NSArray *result);

@interface SKHost : NSObject

/**
 *  根据域名获取IP地址
 *
 *  @param hostName        域名
 *  @param completionBlock 获取域名成功或失败后执行
 */
+ (void)getHostAddressByName:(NSString *)hostName completion:(LCHostCompletionBlock)completionBlock;

//+ (void)getHostNameByAddress:(NSString *)hostName completion:(LCHostCompletionBlock)completionBlock;

@end
