//
//  ZJMediator+ModelB.m
//  ZJURLRoute
//
//  Created by zzt on 2020/6/12.
//  Copyright © 2020 zzt. All rights reserved.
//

#import "ZJMediator+ModelB.h"

@implementation ZJMediator (ModelB)

- (id)getModelBController {
    return [@"ModeBViewController" ZJCallClassAllocInitSelectorName:@"init" error:nil];
}


@end
