/**
 * Created by Weex.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the Apache Licence 2.0.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "WXStorageModule.h"
#import "WXSDKManager.h"
#import "WXThreadSafeMutableDictionary.h"
#import <CommonCrypto/CommonCrypto.h>
#import "WXUtility.h"

static NSString * const WXStorageDirectory            = @"wxstorage";
static NSString * const WXStorageFileName             = @"wxstorage.json";
static NSUInteger const WXStorageLineLimit            = 1024;
static NSString * const WXStorageThreadName           = @"com.taobao.weex.storage";

@implementation WXStorageModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(length:))
WX_EXPORT_METHOD(@selector(getItem:callback:))
WX_EXPORT_METHOD(@selector(setItem:value:callback:))
WX_EXPORT_METHOD(@selector(getAllKeys:))
WX_EXPORT_METHOD(@selector(removeItem:callback:))

#pragma mark - Export

- (void)length:(WXModuleCallback)callback
{
    callback(@{@"result":@"success",@"data":@([[WXStorageModule memory] count])});
}

- (void)getAllKeys:(WXModuleCallback)callback
{
    callback(@{@"result":@"success",@"data":[WXStorageModule memory].allKeys});
}

- (void)getItem:(NSString *)key callback:(WXModuleCallback)callback
{
    if ([key isKindOfClass:[NSString class]] == NO) {
        callback(@{@"result":@"failed",@"data":@"key must a string!"});
        return;
    }
    if ([WXUtility isBlankString:key]) {
        callback(@{@"result":@"failed",@"data":@"invalid_param"});
        return ;
    }
    NSString *value = [self.memory objectForKey:key];
    if (value == (id)kCFNull) {
        value = [[WXUtility globalCache] objectForKey:key];
        if (!value) {
            dispatch_async([WXStorageModule storageQueue], ^{
                NSString *filePath = [WXStorageModule filePathForKey:key];
                NSString *contents = [WXUtility stringWithContentsOfFile:filePath];
                if (contents) {
                    [[WXUtility globalCache] setObject:contents forKey:key cost:contents.length];
                    callback(@{@"result":@"success",@"data":contents});
                } else {
                    [self.memory removeObjectForKey:key];
                    callback(@{@"result":@"failed"});
                }
            });
        }
    }
    if (!value) {
        callback(@{@"result":@"failed"});
        return ;
    }
    callback(@{@"result":@"success",@"data":value});
}

- (void)setItem:(NSString *)key value:(NSString *)value callback:(WXModuleCallback)callback
{
    if ([key isKindOfClass:[NSString class]] == NO) {
        callback(@{@"result":@"failed",@"data":@"key must a string!"});
        return;
    }
    if ([value isKindOfClass:[NSString class]] == NO) {
        callback(@{@"result":@"failed",@"data":@"value must a string!"});
        return;
    }
    if ([WXUtility isBlankString:key]) {
        callback(@{@"result":@"failed",@"data":@"invalid_param"});
        return ;
    }
    [self setObject:value forKey:key];
    callback(@{@"result":@"success"});
}

- (void)removeItem:(NSString *)key callback:(WXModuleCallback)callback
{
    if ([key isKindOfClass:[NSString class]] == NO) {
        callback(@{@"result":@"failed",@"data":@"key must a string!"});
        return;
    }
    if (self.memory[key] == (id)kCFNull) {
        [self.memory removeObjectForKey:key];
        dispatch_async([WXStorageModule storageQueue], ^{
            NSString *filePath = [WXStorageModule filePathForKey:key];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            [[WXUtility globalCache] removeObjectForKey:key];
        });
    } else if (self.memory[key]) {
        [self.memory removeObjectForKey:key];
        NSDictionary *dict = [self.memory copy];
        __weak typeof(self) weakSelf = self;
        dispatch_async([WXStorageModule storageQueue], ^{
            WXStorageModule *strongSelf = weakSelf;
            [strongSelf write:dict toFilePath:[WXStorageModule filePath]];
        });
    }
    callback(@{@"result":@"success"});
}

#pragma mark - Utils

- (void)setObject:(NSString *)obj forKey:(NSString *)key{
    
    NSString *filePath = [WXStorageModule filePathForKey:key];
    
    if (obj.length <= WXStorageLineLimit) {
        if (self.memory[key] == (id)kCFNull) {
            [[WXUtility globalCache] removeObjectForKey:key];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        self.memory[key] = obj;
        __weak typeof(self) weakSelf = self;
        NSDictionary *dict = [self.memory copy];
        dispatch_async([WXStorageModule storageQueue], ^{
            WXStorageModule *strongSelf = weakSelf;
            [strongSelf write:dict toFilePath:[WXStorageModule filePath]];
        });
        
        return;
    }
    
    [[WXUtility globalCache] setObject:obj forKey:key cost:obj.length];
    
    dispatch_async([WXStorageModule storageQueue], ^{
        [obj writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    });
    
    if (self.memory[key] != (id)kCFNull) {
        self.memory[key] = (id)kCFNull;
        __weak typeof(self) weakSelf = self;
        NSDictionary *dict = [self.memory copy];
        dispatch_async([WXStorageModule storageQueue], ^{
            WXStorageModule *strongSelf = weakSelf;
            [strongSelf write:dict toFilePath:[WXStorageModule filePath]];
        });
    }
}

- (void)write:(NSDictionary *)dict toFilePath:(NSString *)filePath{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:(NSJSONWritingOptions)0
                                                         error:&error];
    if (error) {
        return ;
    }
    NSString *contents = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [contents writeToFile:filePath
                      atomically:YES
                        encoding:NSUTF8StringEncoding
                           error:NULL];

}

+ (NSString *)filePathForKey:(NSString *)key
{
    NSString *safeFileName = [WXUtility md5:key];
    
    return [[WXStorageModule directory] stringByAppendingPathComponent:safeFileName];
}

+ (void)setupDirectory{
    BOOL isDirectory = NO;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[WXStorageModule directory] isDirectory:&isDirectory];
    if (!isDirectory && !fileExists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[WXStorageModule directory]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
}

+ (NSString *)directory {
    static NSString *storageDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storageDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        storageDirectory = [storageDirectory stringByAppendingPathComponent:WXStorageDirectory];
    });
    return storageDirectory;
}

+ (NSString *)filePath {
    static NSString *storageFilePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storageFilePath = [[WXStorageModule directory] stringByAppendingPathComponent:WXStorageFileName];
    });
    return storageFilePath;
}

+ (dispatch_queue_t)storageQueue {
    static dispatch_queue_t storageQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storageQueue = dispatch_queue_create("com.taobao.weex.storage", DISPATCH_QUEUE_SERIAL);
    });
    return storageQueue;
}

+ (WXThreadSafeMutableDictionary<NSString *, NSString *> *)memory {
    static WXThreadSafeMutableDictionary<NSString *,NSString *> *memory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [WXStorageModule setupDirectory];
        
        NSString *contents = [WXUtility stringWithContentsOfFile:[WXStorageModule filePath]];
        if (contents) {
            memory = [[WXThreadSafeMutableDictionary alloc] initWithDictionary:[WXUtility objectFromJSON:contents]];
        }
        if (!memory) {
            memory = [WXThreadSafeMutableDictionary new];
        }
    });
    return memory;
}

- (WXThreadSafeMutableDictionary<NSString *, NSString *> *)memory {
    return [WXStorageModule memory];
}

@end

