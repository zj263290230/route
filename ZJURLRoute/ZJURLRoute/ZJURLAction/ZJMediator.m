//
//  ZJMediator.m
//  ZJURLRoute
//
//  Created by zzt on 2020/6/11.
//  Copyright © 2020 zzt. All rights reserved.
//

#import "ZJMediator.h"

@implementation ZJMediator

+ (instancetype)sharedInstance {
    static ZJMediator *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[ZJMediator alloc] init];
    });
    
    return mediator;
}



@end
