//
//  ModeBViewController.m
//  ZJURLRoute
//
//  Created by zzt on 2020/6/12.
//  Copyright © 2020 zzt. All rights reserved.
//

#import "ModeBViewController.h"

@interface ModeBViewController ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation ModeBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.label.frame = CGRectMake(100, 100, 100, 200);
    [self.view addSubview:self.label];
}



- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.text = @"modelB";
    }
    return _label;
}
@end
