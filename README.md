# HostResolutionDemo

根据域名获取对应的IP地址

**Usage:**

```obj-c
[SKHost getHostAddressByName:@"www.baidu.com" completion:^(BOOL completion, NSArray *result) {
        NSLog(@"completion: %@", result);
}];
```
