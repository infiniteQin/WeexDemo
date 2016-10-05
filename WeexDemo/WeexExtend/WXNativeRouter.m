//
//  WXNativeRouter.m
//  WeexDemo
//
//  Created by taizi on 16/10/5.
//  Copyright © 2016年 taizi. All rights reserved.
//

#import "WXNativeRouter.h"
#import "ViewController.h"

@implementation WXNativeRouter

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(pushToVC:params:callback:))
-(void)pushToVC:(NSString*)vcId params:(NSDictionary*)params callback:(WXModuleCallback)callback {
    ViewController *vc = [[ViewController alloc] init];
    [weexInstance.viewController.navigationController pushViewController:vc animated:YES];
    if (callback) {
        callback(@"did push");
    }
}

@end
