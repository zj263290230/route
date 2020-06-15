//
//  UINavigationController+ZJURLAction.h
//  ZJURLRoute
//
//  Created by zzt on 2020/6/12.
//  Copyright © 2020 zzt. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (ZJURLAction)

- (void)pushURL:(NSURL *)url animated:(BOOL)animated;

- (void)pushURLString:(NSString *)urlString animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
