//
//  ViewController.m
//  WeexDemo
//
//  Created by taizi on 16/8/8.
//  Copyright © 2016年 taizi. All rights reserved.
//

#import "ViewController.h"
#import <WeexSDK/WeexSDK.h>
#import <WeexSDK/WXView.h>
#import "WXSDImageDownloadImp.h"
#import "WXNativeRouter.h"

@interface ViewController ()
@property (nonatomic, strong) WXSDKInstance *instance;
@property (nonatomic, strong) WXView        *weexView;
@property (nonatomic, strong) UIButton      *reloadBtn;
@end



@implementation ViewController

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [WXAppConfiguration setAppGroup:@"AliApp"];
        [WXAppConfiguration setAppName:@"WeexDemo"];
        [WXAppConfiguration setAppVersion:@"1.0.0"];
        
        //init sdk enviroment
        [WXSDKEngine initSDKEnviroment];
        
        [WXSDKEngine registerHandler:[WXSDImageDownloadImp new] withProtocol:@protocol(WXImgLoaderProtocol)];
        
        [WXSDKEngine registerModule:@"router" withClass:[WXNativeRouter class]];
        //set the log level
        [WXLog setLogLevel: WXLogLevelDebug];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:self.reloadBtn];
    [self relaodWeView];
}

- (void)relaodWeView {
    
//    __weak typeof(self) wSelf = self;
//    _instance.refreshFinish = ^(UIView *view) {
////        [wSelf.view addSubview:view];
////        [view layoutIfNeeded];
//        [wSelf.view insertSubview:view belowSubview:wSelf.reloadBtn];
//    };
//    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [self.view addSubview:self.reloadBtn];
//    [_instance refreshInstance:_instance];
    [_instance destroyInstance];
    
    _instance = [[WXSDKInstance alloc] init];
    _instance.viewController = self;
    _instance.frame = self.view.frame;
    
    __weak typeof(self) wSelf = self;
    _instance.onCreate = ^(UIView *view) {
        //        [view removeFromSuperview];
        [wSelf.view addSubview:view];
        [wSelf.view bringSubviewToFront:wSelf.reloadBtn];
    };
    
    _instance.onFailed = ^(NSError *error) {
        //process failure
    };
    
    _instance.renderFinish = ^ (UIView *view) {
        //process renderFinish
    };
    
    NSURL *weexURL = [NSURL URLWithString:@"http://127.0.0.1:8081/main.we"];
    [_instance renderWithURL:weexURL ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_instance destroyInstance];
}

- (UIButton *)reloadBtn {
    if (!_reloadBtn) {
        _reloadBtn = [UIButton new];
        [_reloadBtn setTitle:@"ReLoad" forState:UIControlStateNormal];
        [_reloadBtn addTarget:self action:@selector(relaodWeView) forControlEvents:UIControlEventTouchUpInside];
        [_reloadBtn sizeToFit];
        _reloadBtn.backgroundColor = [UIColor lightGrayColor];
        _reloadBtn.center = self.view.center;
    }
    return _reloadBtn;
}

@end
