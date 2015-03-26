//
//  SKHost.m
//  HostResolutionDemo
//
//  Created by ChenHao on 15/3/26.
//  Copyright (c) 2015年 ChenHao. All rights reserved.
//

#import "SKHost.h"

#import <CFNetwork/CFNetwork.h>
#import <netinet/in.h>
#import <arpa/inet.h>

// 回调函数
void host_client_callback(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info);
const void * host_retain_callback(const void *info);
void host_release_callback(const void *info);
CFStringRef	host_copy_description_callback(const void *info);


@interface SKHost()

@property (nonatomic, strong) LCHostCompletionBlock completionBlock;
@property (nonatomic, strong) NSArray *hostNames;
@property (nonatomic, strong) NSArray *hostAddresses;

- (instancetype)initWithHostName:(NSString *)hostName;
- (instancetype)initWithHostAddress:(NSString *)hostAddress;

@end

@implementation SKHost


+ (void)getHostAddressByName:(NSString *)hostName completion:(LCHostCompletionBlock)completionBlock
{
    SKHost *instance = [[SKHost alloc] initWithHostName:hostName];
    instance.completionBlock = completionBlock;
    
    CFHostRef host = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostName);
    CFHostClientContext context;
    context.version = 0;
    context.info = (__bridge void *)instance;
    context.retain = host_retain_callback;
    context.release = host_release_callback;
    context.copyDescription = NULL;//host_copy_description_callback;//
    
    BOOL ret = CFHostSetClient(host, host_client_callback, &context);
    CFHostScheduleWithRunLoop(host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    ret = CFHostStartInfoResolution(host, kCFHostAddresses, NULL);
    
    if (!ret) {
        CFHostUnscheduleFromRunLoop(host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFHostSetClient(host, NULL, NULL);
        if (completionBlock) {
            completionBlock(NO, nil);
        }
    }
    
    CFRelease(host);
}

+ (void)getHostNameByAddress:(NSString *)hostAddress completion:(LCHostCompletionBlock)completionBlock
{
    //TODO: 还有问题
    SKHost *instance = [[SKHost alloc] initWithHostAddress:hostAddress];
    instance.completionBlock = completionBlock;
    
    in_addr_t add = inet_addr([hostAddress cStringUsingEncoding:NSUTF8StringEncoding]);
    struct sockaddr_in sock_ptr = {0};
    sock_ptr.sin_len = sizeof(struct sockaddr_in);
    sock_ptr.sin_family = AF_INET;
    sock_ptr.sin_port = 0;
    sock_ptr.sin_addr.s_addr = add;
    
    CFHostRef host = CFHostCreateWithAddress(kCFAllocatorDefault, CFDataCreate(kCFAllocatorDefault, (const UInt8 *)&sock_ptr, sizeof(sock_ptr)));
    CFHostClientContext context;
    context.version = 0;
    context.info = (__bridge void *)instance;
    context.retain = NULL;//host_retain_callback;
    context.release = NULL;//host_release_callback;
    context.copyDescription = NULL;//host_copy_description_callback
    
    BOOL ret = CFHostSetClient(host, host_client_callback, &context);
    CFHostScheduleWithRunLoop(host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    ret = CFHostStartInfoResolution(host, kCFHostNames, NULL);
    
    if (ret) {
        NSLog(@"start...");
    } else {
        CFHostUnscheduleFromRunLoop(host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFHostSetClient(host, NULL, NULL);
        if (completionBlock) {
            completionBlock(NO, nil);
        }
    }
    
    CFRelease(host);
}

- (void)dealloc
{
//    NSLog(@"dealloc.");
}

- (instancetype)initWithHostName:(NSString *)hostName
{
    self = [super init];
    if (self) {
        _hostNames = [NSArray arrayWithObjects:hostName, nil];
    }
    
    return self;
}

- (instancetype)initWithHostAddress:(NSString *)hostAddress
{
    self = [super init];
    if (self) {
        _hostAddresses = [NSArray arrayWithObjects:hostAddress, nil];
    }
    
    return self;
}

@end


void host_client_callback(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info)
{
    Boolean flag;
    NSMutableArray * result = [NSMutableArray array];
    
    if (typeInfo == kCFHostNames) {
        // TODO: 取得解析的域名
        NSArray * array = (__bridge NSArray *)CFHostGetNames(theHost, &flag);
        if (flag) {
            NSLog(@"names: %@", array);
        }
    } else if (typeInfo == kCFHostAddresses) {
        //取得解析的ip地址
        NSArray * array = (__bridge NSArray *)CFHostGetAddressing(theHost, &flag);
        if (flag) {
            struct sockaddr_in *sock_ptr;
            for(NSData * ipaddr in array)
            {
                sock_ptr = (struct sockaddr_in *)[ipaddr bytes];
                NSString * ip = [NSString stringWithUTF8String:inet_ntoa(sock_ptr->sin_addr)];
                
                [result addObject:ip];
            }
        }
    }
    
    CFHostUnscheduleFromRunLoop(theHost, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    CFHostSetClient(theHost, NULL, NULL);
    
    SKHost *instance = (__bridge SKHost *)info;
    if (instance.completionBlock) {
        instance.completionBlock((!error || error->error == 0), result);
    }
}

const void * host_retain_callback(const void *info)
{
    NSLog(@"retain info: %@", info);
    
    return CFRetain(info);
}

void host_release_callback(const void *info)
{
    NSLog(@"release info: %@", info);
    
    CFRelease(info);
}

CFStringRef	host_copy_description_callback(const void *info)
{
    SKHost *host = (__bridge SKHost *)info;
    return (__bridge CFStringRef)[host debugDescription];
}
