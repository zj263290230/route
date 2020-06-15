//
//  ZJURLParser.h
//  ZJURLRoute
//
//  Created by zzt on 2020/6/11.
//  Copyright © 2020 zzt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZJURLParser : NSObject

@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *signSalt;

- (void)mapKeyword:(NSString *)key toActionName:(NSString *)action;
- (BOOL)parseURL:(NSURL *)url toAction:(NSString *__autoreleasing*)action toParamDic:(NSDictionary *__autoreleasing*)param;

- (NSString *)creatNewNativeBaseUrl;
- (NSString *)appendAction:(NSString *)action toBaseURL:(NSString *)url;
- (NSString *)appendArgumentToHalfURL:(NSString *)url withKey:(NSString *)key andValue:(NSString *)value;
- (NSString *)appendSignCheckToURL:(NSString *)urlstr;


@end

NS_ASSUME_NONNULL_END
