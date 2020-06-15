//
//  ZJURLAction.h
//  ZJURLRoute
//
//  Created by zzt on 2020/6/11.
//  Copyright © 2020 zzt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZJURLParser;
NS_ASSUME_NONNULL_BEGIN

@interface ZJURLAction : NSObject

@property (nonatomic, strong) ZJURLParser *urlParser;

+ (instancetype)sharedInstance;

+ (void)setupScheme:(NSString *)scheme andHost:(NSString *)host;
- (void)setupScheme:(NSString *)scheme andHost:(NSString *)host;

+ (void)enableSignCheck:(NSString *)signSalt;
- (void)enableSignCheck:(NSString *)signSalt;

+ (void)mapKeyword:(NSString *)key toActionName:(NSString *)action;
- (void)mapKeyword:(NSString *)key toActionName:(NSString *)action;

+ (id)doActionWithURL:(NSURL *)url;
- (id)doActionWithURL:(NSURL *)url;

+ (id)doActionWithURLString:(NSString *)urlString;
- (id)doActionWithURLString:(NSString *)urlString;

+ (NSString *)createNewNativeBaseUrl;
- (NSString *)createNewNativeBaseUrl;

+ (NSString *)appendAction:(NSString *)action toBaseUrl:(NSString *)url;
- (NSString *)appendAction:(NSString *)action toBaseUrl:(NSString *)url;

+ (NSString *)appendArgumentToHalfURL:(NSString *)url withkey:(NSString *)key andValue:(NSString *)value;
- (NSString *)appendArgumentToHalfURL:(NSString *)url withkey:(NSString *)key andValue:(NSString *)value;

+ (NSString *)appendSignCheckToURL:(NSString *)url;
- (NSString *)appendSignCheckToURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
