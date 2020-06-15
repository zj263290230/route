//
//  NSURL+ZJURL.h
//  ZJURLRoute
//
//  Created by zzt on 2020/6/11.
//  Copyright © 2020 zzt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (ZJURL)
- (NSURL *)addParams:(NSDictionary *)params;
- (NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
