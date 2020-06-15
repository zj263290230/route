//
//  ModelAViewController.m
//  ZJURLRoute
//
//  Created by zzt on 2020/6/12.
//  Copyright © 2020 zzt. All rights reserved.
//

#import "ModelAViewController.h"
#import <WebKit/WebKit.h>

@interface ModelAViewController ()
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) WKWebView *webview;
@end

@implementation ModelAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webview];
    self.webview.frame = self.view.bounds;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

- (instancetype)initWithTitle:(NSString *)title url:(NSString *)urlStr {
    self = [super init];
    if (self) {
        self.title = title;
        self.url = urlStr;
        self.titleString = title;
    }
    return self;
}


- (void)doAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标题" message:self.url preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (WKWebView *)webview {
    if (!_webview) {
        _webview = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[[WKWebViewConfiguration alloc] init]];
    }
    return _webview;
}

@end
