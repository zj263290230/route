//
//  ZJURLAction.m
//  ZJURLRoute
//
//  Created by zzt on 2020/6/11.
//  Copyright © 2020 zzt. All rights reserved.
//

#import "ZJURLAction.h"
#import "ZJURLParser.h"
#import "ZJMediator.h"
#import "ZJMsgSend.h"

@implementation ZJURLAction

+ (instancetype)sharedInstance {
    static ZJURLAction *action;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        action = [[ZJURLAction alloc] init];
    });
    
    return action;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.urlParser = [[ZJURLParser alloc] init];
    }
    return self;
}

+ (void)setupScheme:(NSString *)scheme andHost:(NSString *)host {
    [[self sharedInstance] setupScheme:scheme andHost:host];
}

- (void)setupScheme:(NSString *)scheme andHost:(NSString *)host {
    self.urlParser.scheme = scheme;
    self.urlParser.host = host;
}

+ (void)enableSignCheck:(NSString *)signSalt {
    [[self sharedInstance] enableSignCheck:signSalt];
}

- (void)enableSignCheck:(NSString *)signSalt {
    self.urlParser.signSalt = signSalt;
}

+ (void)mapKeyword:(NSString *)key toActionName:(NSString *)action {
    [[self sharedInstance] mapKeyword:key toActionName:action];
}

- (void)mapKeyword:(NSString *)key toActionName:(NSString *)action {
    [self.urlParser mapKeyword:key toActionName:action];
}

+ (id)doActionWithURL:(NSURL *)url {
    return [[self sharedInstance] doActionWithURL:url];
}

- (id)doActionWithURL:(NSURL *)url {
    NSString *actionName = @"";
    NSDictionary *paramDic = [NSDictionary dictionary];
    BOOL canOpenUrl = [self.urlParser parseURL:url toAction:&actionName toParamDic:&paramDic];
    
    if (canOpenUrl) {
        NSError *error = nil;
        NSString *actionNamePlus = [actionName stringByAppendingString:@":"];
        
        id result = nil;
        if ([[ZJMediator sharedInstance] respondsToSelector:NSSelectorFromString(actionNamePlus)]) {
            result = [[ZJMediator sharedInstance] ZJCallSelectorName:actionNamePlus error:&error,paramDic];
        } else if ([[ZJMediator sharedInstance] respondsToSelector:NSSelectorFromString(actionName)]) {
            result = [[ZJMediator sharedInstance] ZJCallSelectorName:actionName error:&error,paramDic];
        }
    }
    return nil;
}

+ (id)doActionWithURLString:(NSString *)urlString {
    return [[self sharedInstance] doActionWithURLString:urlString];
}

- (id)doActionWithURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    return [self doActionWithURL:url];
}

+ (NSString *)createNewNativeBaseUrl {
    return [[self sharedInstance] createNewNativeBaseUrl];
}

- (NSString *)createNewNativeBaseUrl {
    return [self.urlParser creatNewNativeBaseUrl];
}

+ (NSString *)appendAction:(NSString *)action toBaseUrl:(NSString *)url {
    return [[self sharedInstance] appendAction:action toBaseUrl:url];
}

- (NSString *)appendAction:(NSString *)action toBaseUrl:(NSString *)url{
    return [self.urlParser appendAction:action toBaseURL:url];
}

+ (NSString *)appendArgumentToHalfURL:(NSString *)url withkey:(NSString *)key andValue:(NSString *)value {
    return [[self sharedInstance] appendArgumentToHalfURL:url withkey:key andValue:value];
}

- (NSString *)appendArgumentToHalfURL:(NSString *)url withkey:(NSString *)key andValue:(NSString *)value {
    return [self.urlParser appendArgumentToHalfURL:url withKey:key andValue:value];
}

+ (NSString *)appendSignCheckToURL:(NSString *)url {
    return [[self sharedInstance] appendSignCheckToURL:url];
}

- (NSString *)appendSignCheckToURL:(NSString *)url {
    return [self.urlParser appendSignCheckToURL:url];
}



@end
