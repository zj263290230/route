//
//  NSString+ZJURLString.m
//  ZJURLRoute
//
//  Created by zzt on 2020/6/11.
//  Copyright © 2020 zzt. All rights reserved.
//

#import "NSString+ZJURLString.h"
#include <CommonCrypto/CommonCrypto.h>


@implementation NSString (ZJURLString)

- (NSString *)MD5HexDigest {
    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++) {
        [hash appendFormat:@"%02x",result[i]];
    }
    return [hash lowercaseString];
}

- (NSString *)urldecode {
    return [self stringByRemovingPercentEncoding];
}

- (NSString *)urlencode {
    NSMutableCharacterSet *allowSet = [[NSMutableCharacterSet alloc] init];
    [allowSet formUnionWithCharacterSet:[NSCharacterSet URLHostAllowedCharacterSet]];
    [allowSet formUnionWithCharacterSet:[NSCharacterSet URLPathAllowedCharacterSet]];
    [allowSet formUnionWithCharacterSet:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    [allowSet formUnionWithCharacterSet:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [allowSet addCharactersInString:@"#!*';:&=+$,^"];
    NSString *encUrl = [self stringByAddingPercentEncodingWithAllowedCharacters:allowSet];
    return encUrl;
}
@end
