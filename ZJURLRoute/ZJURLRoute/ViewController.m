//
//  ViewController.m
//  ZJURLRoute
//
//  Created by zzt on 2020/6/11.
//  Copyright © 2020 zzt. All rights reserved.
//

#import "ViewController.h"
#import "ZJMediator+ModelA.h"
#import "ZJMediator+ModelB.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)openModelA:(id)sender {
    UIViewController *vc = [[ZJMediator sharedInstance] getModelAControllerWithTitle:@"title" url:@"https://www.baidu.com"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)openModelB:(id)sender {
    [self.navigationController pushViewController:[[ZJMediator sharedInstance] getModelBController]  animated:YES];
}

@end
