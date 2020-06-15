//
//  NSURL+ZJURL.m
//  ZJURLRoute
//
//  Created by zzt on 2020/6/11.
//  Copyright © 2020 zzt. All rights reserved.
//

#import "NSURL+ZJURL.h"
#import "NSString+ZJURLString.h"

@implementation NSURL (ZJURL)

- (NSURL *)addParams:(NSDictionary *)params {
    NSMutableString *_add = [NSMutableString string];
    if (NSNotFound != [self.absoluteString rangeOfString:@"?"].location) {
        _add = [NSMutableString stringWithString:@"&"];
    } else {
        _add = [NSMutableString stringWithString:@"?"];
    }
    
    for (NSString *key in [params allKeys]) {
        if ([params objectForKey:key] && 0 < [[params objectForKey:key] length]) {
            [_add appendFormat:@"%@=%@",key,[[params objectForKey:key]urlencode]];
        }
    }
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",self.absoluteString, [_add substringToIndex:[_add length] -1]]];
    
}

- (NSDictionary *)params {
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    if (NSNotFound != [self.absoluteString rangeOfString:@"?"].location) {
        NSString *paramString = [self.absoluteString substringFromIndex:([self.absoluteString rangeOfString:@"?"].location + 1)];
        NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&"];
        NSScanner *scanner = [[NSScanner alloc] initWithString:paramString];
        while (![scanner isAtEnd]) {
            @autoreleasepool {
                NSString *pairString = @"";
                [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
                [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
                NSArray *kvPair = [pairString componentsSeparatedByString:@"="];
                if (kvPair.count == 2) {
                    NSString *key = [[kvPair objectAtIndex:0] urldecode];
                    NSString *value = [[kvPair objectAtIndex:1] urldecode];
                    [pairs setValue:value forKey:key];
                }
            }
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}


@end
