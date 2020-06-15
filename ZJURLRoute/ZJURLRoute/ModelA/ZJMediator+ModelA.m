//
//  ZJMediator+ModelA.m
//  ZJURLRoute
//
//  Created by zzt on 2020/6/12.
//  Copyright © 2020 zzt. All rights reserved.
//

#import "ZJMediator+ModelA.h"

@implementation ZJMediator (ModelA)

- (id)getModelAControllerWithTitle:(NSString *)title url:(NSString *)urlStr {
    id vc = [@"ModelAViewController" ZJCallClassAllocInitSelectorName:@"initWithTitle:url:" error:nil, title, urlStr];
    return vc;
}

@end
