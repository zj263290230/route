//
//  ZJURLParser.m
//  ZJURLRoute
//
//  Created by zzt on 2020/6/11.
//  Copyright © 2020 zzt. All rights reserved.
//

#import "ZJURLParser.h"
#import "ZJMediator.h"

#import "NSURL+ZJURL.h"
#import "NSString+ZJURLString.h"

@interface ZJURLParser ()
@property (nonatomic, strong) NSMutableDictionary *shortNameDic;
@end


@implementation ZJURLParser

- (instancetype)init {
    self = [super init];
    if (self) {
        self.shortNameDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)mapKeyword:(NSString *)key toActionName:(NSString *)action {
    if (key && key.length && action && action.length) {
        [self.shortNameDic setObject:action forKey:key];
    }
}

- (BOOL)parseURL:(NSURL *)url toAction:(NSString * __autoreleasing*)action toParamDic:(NSDictionary * __autoreleasing*)param {
    if (![url.scheme isEqualToString:self.scheme]) {
        return NO;
    }
    
    if (![url.host isEqualToString:self.host]) {
        return NO;
    }
    
    NSString *relp = url.relativePath;
    NSArray *pathComponent = [relp componentsSeparatedByString:@"/"];
    NSString *actionName = pathComponent.lastObject;
    NSString *origActionName = @"";
    
    if ([self.shortNameDic objectForKey:actionName]) {
        origActionName = actionName;
        actionName = self.shortNameDic[actionName];
    }
    
    NSString *actionNamePlus = [actionName stringByAppendingString:@":"];
    
    if (actionName && actionName.length &&
        ([ZJMediator instancesRespondToSelector:NSSelectorFromString(actionName)] || [ZJMediator instancesRespondToSelector:NSSelectorFromString(actionNamePlus)])) {
        if (action) {
            *action = actionName;
        }
    } else {
        return NO;
    }
    
    NSDictionary *paramInfo = [url params];
    if (param) {
        *param = paramInfo;
    }
    
    if (self.signSalt && self.signSalt.length > 0) {
        NSMutableString *checkContent;
        if (origActionName.length) {
            checkContent = [[NSMutableString alloc] initWithString:origActionName];
        } else {
            checkContent = [[NSMutableString alloc] initWithString:actionName];
        }
        
        [checkContent appendString:@"_"];
        
        NSString *md5Sign;
        for (NSString *key in paramInfo.allKeys) {
            if (![key containsString:@"sign"]) {
                [checkContent appendString:key];
                [checkContent appendString:@"_"];
                [checkContent appendString:paramInfo[key]];
                [checkContent appendString:@"_"];
            } else {
                md5Sign = paramInfo[key];
            }
        }
        
        [checkContent appendString:self.signSalt];
        NSString *content = [NSString stringWithString:checkContent];
        NSString *contentMD5 = [content MD5HexDigest];
        
        if ([contentMD5 isEqualToString:md5Sign]) {
            return YES;
        } else {
            return NO;
        }
        
    } else {
        // 无签名校验，默认通过
        return YES;
    }
}

- (NSString *)creatNewNativeBaseUrl {
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:self.scheme];
    [urlString appendString:@"://"];
    [urlString appendString:self.host];
    [urlString appendString:@"/"];
    NSString *result = [NSString stringWithString:urlString];
    return result;
}

- (NSString *)appendAction:(NSString *)action toBaseURL:(NSString *)url {
    NSMutableString *urlString = [NSMutableString stringWithString:url];
    [urlString appendString:action];
    NSString *result = [NSString stringWithString:urlString];
    return result;
}

- (NSString *)appendArgumentToHalfURL:(NSString *)url withKey:(NSString *)key andValue:(NSString *)value {
    value = [value urlencode];
    
    NSMutableString *urlString = [NSMutableString stringWithString:url];
    if (![url containsString:@"?"]) {
        [urlString appendString:@"?"];
    } else {
        [urlString appendString:@"&"];
    }
    
    [urlString appendString:key];
    [urlString appendString:@"="];
    [urlString appendString:value];
    
    NSString *result = [NSString stringWithString:urlString];
    return result;
}

- (NSString *)appendSignCheckToURL:(NSString *)urlstr {
    
    if (!self.signSalt.length) {
        return urlstr;
    }
    
    NSMutableString *urlString = [NSMutableString stringWithString:urlstr];
    
    NSURL *url = [NSURL URLWithString:urlstr];
    
    NSString *relp = url.relativePath;
    NSArray *pathComponent = [relp componentsSeparatedByString:@"/"];
    NSString *actionName = pathComponent.lastObject;
    
    NSMutableString *checkContent = [[NSMutableString alloc] initWithString:actionName];
    [checkContent appendString:@"_"];
    NSDictionary *paramInfo = [url params];
    NSString *md5Sign;
    for (NSString *key in paramInfo) {
        if (![key containsString:@"sign"]) {
            [checkContent appendString:key];
            [checkContent appendString:@"_"];
            [checkContent appendString:paramInfo[key]];
            [checkContent appendString:@"_"];
        } else {
            md5Sign = paramInfo[key];
        }
    }
    [checkContent appendString:self.signSalt];
    NSString *content = [NSString stringWithString:checkContent];
    NSString *contenMD5 = [content MD5HexDigest];
    
    if (![urlString containsString:@"?"]) {
        [urlString appendString:@"?"];
    } else {
        [urlString appendString:@"&"];
    }
    
    [urlString appendString:@"sign"];
    [urlString appendString:@"="];
    [urlString appendString:contenMD5];
    
    NSString *result = [NSString stringWithString:urlString];
    
    return result;
    
}

@end
