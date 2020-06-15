//
//  ZJMsgSend.h
//  ZJURLRoute
//
//  Created by zzt on 2020/6/11.
//  Copyright © 2020 zzt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZJMsgSend)

+ (id)ZJCallSelector:(SEL)selector error:(NSError * __autoreleasing *)error,...;

+ (id)ZJCallSelectorName:(NSString *)selName error:(NSError * __autoreleasing *)error,...;

- (id)ZJCallSelector:(SEL)selector error:(NSError * __autoreleasing *)error,...;

- (id)ZJCallSelectorName:(NSString *)selName error:(NSError * __autoreleasing *)error,...;

@end


@interface NSString (ZJMsgSend)

- (id)ZJCallClassSelector:(SEL)selector error:(NSError * __autoreleasing *)error,...;

- (id)ZJCallClassSelectorName:(NSString *)selName error:(NSError * __autoreleasing *)error,...;

- (id)ZJCallClassAllocInitSelector:(SEL)selector error:(NSError * __autoreleasing *)error,...;

- (id)ZJCallClassAllocInitSelectorName:(NSString *)selName error:(NSError * __autoreleasing *)error,...;

@end

NS_ASSUME_NONNULL_END
