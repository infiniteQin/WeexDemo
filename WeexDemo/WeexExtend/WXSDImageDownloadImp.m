//
//  WXSDImageDownloadImp.m
//  WeexDemo
//
//  Created by taizi on 16/8/8.
//  Copyright © 2016年 taizi. All rights reserved.
//

#import "WXSDImageDownloadImp.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation WXSDImageDownloadImp

- (id<WXImageOperationProtocol>)downloadImageWithURL:(NSString *)urlStr imageFrame:(CGRect)imageFrame userInfo:(NSDictionary *)options completed:(void(^)(UIImage *image,  NSError *error, BOOL finished))completedBlock {
    if ([urlStr hasPrefix:@"//"]) {
        urlStr = [@"http:" stringByAppendingString:urlStr];
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    return (id<WXImageOperationProtocol>)[[SDWebImageManager sharedManager] downloadImageWithURL:url options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        completedBlock(image,error,finished);
    }];
}

@end
