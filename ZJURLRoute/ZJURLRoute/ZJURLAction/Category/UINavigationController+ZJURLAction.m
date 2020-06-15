//
//  UINavigationController+ZJURLAction.m
//  ZJURLRoute
//
//  Created by zzt on 2020/6/12.
//  Copyright © 2020 zzt. All rights reserved.
//

#import "UINavigationController+ZJURLAction.h"
#import "ZJURLAction.h"

@implementation UINavigationController (ZJURLAction)

- (void)pushURL:(NSURL *)url animated:(BOOL)animated {
    id vc = [[ZJURLAction sharedInstance] doActionWithURL:url];
    if ([vc isKindOfClass:[UIViewController class]]) {
        [self pushViewController:vc animated:animated];
    }
}

- (void)pushURLString:(NSString *)urlString animated:(BOOL)animated {
    id vc = [[ZJURLAction sharedInstance] doActionWithURLString:urlString];
    if ([vc isKindOfClass:[UIViewController class]]) {
        [self pushViewController:vc animated:animated];
    }
}


@end
