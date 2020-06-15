//
//  ZJMsgSend.m
//  ZJURLRoute
//
//  Created by zzt on 2020/6/11.
//  Copyright © 2020 zzt. All rights reserved.
//

#import "ZJMsgSend.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIApplication.h>
#endif


#pragma mark : zk_nilObject

@interface zj_pointer : NSObject

@property (nonatomic) void *pointer;

@end

@implementation zj_pointer

@end

@interface zj_nilObject : NSObject

@end

@implementation zj_nilObject

@end

#pragma mark : static

static NSLock *_zjMethodSignatureLock;
static NSMutableDictionary *_zjMethodSignatureCache;
static zj_nilObject *zjnilPointer = nil;


static NSString *zj_extractStructName(NSString *typeEncodeString) {
    
    NSArray *array = [typeEncodeString componentsSeparatedByString:@"="];
    NSString *typeString = array[0];
    __block int firstValueIndex = 0;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UniChar c = [typeEncodeString characterAtIndex:idx];
        if (c == '{' || c == '_') {
            firstValueIndex ++;
        } else {
            *stop = YES;
        }
    }];
    return [typeString substringFromIndex:firstValueIndex];
};


static NSString *zj_selectorName(SEL selector) {
    const char *selNameCStr = sel_getName(selector);
    NSString *selName = [[NSString alloc] initWithUTF8String:selNameCStr];
    return selName;
};

static NSMethodSignature *zj_getMethodSignature(Class cls, SEL selector) {
    [_zjMethodSignatureLock lock];
    
    if (!_zjMethodSignatureCache) {
        _zjMethodSignatureCache = [[NSMutableDictionary alloc] init];
    }
    if (!_zjMethodSignatureCache[cls]) {
        _zjMethodSignatureCache[(id<NSCopying>)cls] = [[NSMutableDictionary alloc] init];
    }
    NSString *selName = zj_selectorName(selector);
    NSMethodSignature *methodSignature = _zjMethodSignatureCache[cls][selName];
    if (!methodSignature) {
        methodSignature = [cls instanceMethodSignatureForSelector:selector];
    } else {
        methodSignature = [cls methodSignatureForSelector:selector];
        if (methodSignature) {
            _zjMethodSignatureCache[cls][selName] = methodSignature;
        }
    }
    
    [_zjMethodSignatureLock unlock];
    return methodSignature;
};

static void zj_generateError(NSString *errorInfo, NSError **error) {
    if (error) {
        *error = [NSError errorWithDomain:errorInfo code:0 userInfo:nil];
    }
};

static id zj_targetCallSelectorWithArgumentError(id target, SEL selector, NSArray *argsArr, NSError * __autoreleasing *error) {
    
    Class cls = [target class];
    NSMethodSignature *methodSignature = zj_getMethodSignature(cls, selector);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    
    NSMutableArray *_markArray = [NSMutableArray array];
    for (NSUInteger i = 2; i < [methodSignature numberOfArguments]; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        id valObj = argsArr[i -2];
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {

#define ZJ_CALL_ARG_CASE(_typeString, _type, _selector) \
case _typeString: {\
_type value = [valObj _selector];\
[invocation setArgument:&value atIndex:i];\
break;\
}\

            ZJ_CALL_ARG_CASE('c', char, charValue)
            ZJ_CALL_ARG_CASE('C', unsigned char, unsignedCharValue)
            ZJ_CALL_ARG_CASE('s', short, shortValue)
            ZJ_CALL_ARG_CASE('S', unsigned short, unsignedShortValue)
            ZJ_CALL_ARG_CASE('i', int, intValue)
            ZJ_CALL_ARG_CASE('I', unsigned int, unsignedIntValue)
            ZJ_CALL_ARG_CASE('l', long, longValue)
            ZJ_CALL_ARG_CASE('L', unsigned long, unsignedLongValue)
            ZJ_CALL_ARG_CASE('q', long long, longLongValue)
            ZJ_CALL_ARG_CASE('Q', unsigned long long, unsignedLongLongValue)
            ZJ_CALL_ARG_CASE('f', float, floatValue)
            ZJ_CALL_ARG_CASE('d', double, doubleValue)
            ZJ_CALL_ARG_CASE('B', BOOL, boolValue)
                
            case ':': {
                NSString *selName = valObj;
                SEL selValue = NSSelectorFromString(selName);
                [invocation setArgument:&selValue atIndex:i];
            }
                break;
            case '{': {
                NSString *typeString = zj_extractStructName([NSString stringWithUTF8String:argumentType]);
                NSValue *val = (NSValue *)valObj;
#define zj_CALL_ARG_STRUCT(_type, _methodName) \
if([typeString rangeOfString:@#_type].location != NSNotFound) { \
_type value = [val _methodName];    \
[invocation setArgument:&value atIndex:i];\
break;\
}\

                zj_CALL_ARG_STRUCT(CGRect, CGRectValue)
                zj_CALL_ARG_STRUCT(CGPoint, CGPointValue)
                zj_CALL_ARG_STRUCT(CGSize, CGSizeValue)
                zj_CALL_ARG_STRUCT(NSRange, rangeValue)
                zj_CALL_ARG_STRUCT(CGAffineTransform, CGAffineTransformValue)
                zj_CALL_ARG_STRUCT(UIEdgeInsets, UIEdgeInsetsValue)
                zj_CALL_ARG_STRUCT(UIOffset, UIOffsetValue)
                zj_CALL_ARG_STRUCT(CGVector, CGVectorValue)
                
            }
                break;
            case '*': {
                NSCAssert(NO, @"argument boxing wrong, char* is not supported");
            }
                break;
            case '^': {
                zj_pointer *value = valObj;
                void *pointer = value.pointer;
                id obj = *((__unsafe_unretained id *)pointer);
                if (!obj) {
                    if (argumentType[1] == '@') {
                        if (!_markArray) {
                            _markArray = [[NSMutableArray alloc] init];
                        }
                        [_markArray addObject:valObj];
                    }
                }
                [invocation setArgument:&pointer atIndex:i];
            }
                break;
            case '#': {
                [invocation setArgument:&valObj atIndex:i];
            }
                break;
                
            default: {
                if ([valObj isKindOfClass:[zj_nilObject class]]) {
                    [invocation setArgument:&zjnilPointer atIndex:i];
                } else {
                    [invocation setArgument:&valObj atIndex:i];
                }
            }
        }
    }
    
    [invocation invoke];
    
    if ([_markArray count] > 0) {
        for (zj_pointer *pointerObj in _markArray) {
            void *pointer = pointerObj.pointer;
            id obj = *(__unsafe_unretained id *)(pointer);
            if (obj) {
                CFRetain((__bridge CFTypeRef)(obj));
            }
        }
    }
    
    const char *returnType = [methodSignature methodReturnType];
    NSString *selName = zj_selectorName(selector);
    if (strncmp(returnType, "v", 1) != 0) {
        if (strncmp(returnType, "@", 1) == 0) {
            void *result;
            [invocation getReturnValue:&result];
            if (result == NULL) {
                return nil;
            }
            
            id returnValue;
            if ([selName isEqualToString:@"alloc"] || [selName isEqualToString:@"new"] || [selName isEqualToString:@"copy"] || [selName isEqualToString:@"mutableCopy"]) {
                returnValue = (__bridge_transfer id)result;
            } else {
                returnValue = (__bridge id)result;
            }
            return returnValue;
        } else {
            switch (returnType[0] == 'r' ? returnType[1] : returnType[0]) {
#define zj_CALL_RET_CASE(_typeString, _type)\
case _typeString:{\
_type returnValue;\
[invocation getReturnValue:&returnValue];\
return @(returnValue);\
break;\
}\

                zj_CALL_RET_CASE('c', char)
                zj_CALL_RET_CASE('C', unsigned char)
                zj_CALL_RET_CASE('s', short)
                zj_CALL_RET_CASE('S', unsigned short)
                zj_CALL_RET_CASE('i', int)
                zj_CALL_RET_CASE('I', unsigned int)
                zj_CALL_RET_CASE('l', long)
                zj_CALL_RET_CASE('L', unsigned long)
                zj_CALL_RET_CASE('q', long long)
                zj_CALL_RET_CASE('Q', unsigned long long)
                zj_CALL_RET_CASE('f', float)
                zj_CALL_RET_CASE('d', double)
                zj_CALL_RET_CASE('B', BOOL)
                    
                case '{': {
                    NSString *typeString = zj_extractStructName([NSString stringWithUTF8String:returnType]);
#define zj_CALL_RET_STRUCT(_type) \
if([typeString rangeOfString:@#_type].location != NSNotFound) {\
_type result;\
[invocation getReturnValue:&result];\
NSValue *returnValue = [NSValue valueWithBytes:&(result) objCType:@encode(_type)];\
return returnValue;\
                }\

                    zj_CALL_RET_STRUCT(CGRect)
                    zj_CALL_RET_STRUCT(CGPoint)
                    zj_CALL_RET_STRUCT(CGSize)
                    zj_CALL_RET_STRUCT(NSRange)
                    zj_CALL_RET_STRUCT(CGAffineTransform)
                    zj_CALL_RET_STRUCT(UIEdgeInsets)
                    zj_CALL_RET_STRUCT(UIOffset)
                    zj_CALL_RET_STRUCT(CGVector)
                }
                    break;
                case '*': {
                    
                }
                    break;
                case '^':{
                    
                }
                    break;
                case '#':{
                    
                }
                    break;
            }
            return nil;
        }
    }
    
    return nil;
};


static NSArray *zj_targetBoxingArguments(va_list argList, Class cls, SEL selector, NSError *__autoreleasing *error) {
    NSMethodSignature *methodSignature = zj_getMethodSignature(cls, selector);
    NSString *selName = zj_selectorName(selector);
    
    if (!methodSignature) {
        NSString *errStr = [NSString stringWithFormat:@"unrecognized selector (%@)", selName];
        zj_generateError(errStr, error);
        return nil;
    }
    NSMutableArray *argumentBoxingArray = [[NSMutableArray alloc] init];
    for (NSUInteger i = 2; i < [methodSignature numberOfArguments]; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
        
#define zj_BOXING_ARG_CASE(_typeString, _type)\
case _typeString: {\
_type value = va_arg(argList, _type);\
[argumentBoxingArray addObject:@(value)];\
break;\
}\

            zj_BOXING_ARG_CASE('c', int)
            zj_BOXING_ARG_CASE('C', int)
            zj_BOXING_ARG_CASE('s', int)
            zj_BOXING_ARG_CASE('S', int)
            zj_BOXING_ARG_CASE('i', int)
            zj_BOXING_ARG_CASE('I', unsigned int)
            zj_BOXING_ARG_CASE('L', unsigned long)
            zj_BOXING_ARG_CASE('q', long long)
            zj_BOXING_ARG_CASE('Q', unsigned long long)
            zj_BOXING_ARG_CASE('f', double)
            zj_BOXING_ARG_CASE('d', double)
            zj_BOXING_ARG_CASE('B', int)
                
            case ':': {
                SEL value = va_arg(argList, SEL);
                NSString *selValueName = NSStringFromSelector(value);
                [argumentBoxingArray addObject:selValueName];
            }
                break;
            case '{': {
                NSString *typeString = zj_extractStructName([NSString stringWithUTF8String:argumentType]);
                
#define zj_FWD_ARG_STRUCT(_type, _methodName) \
if([typeString rangeOfString:@#_type].location != NSNotFound) {\
_type val = va_arg(argList, _type);\
NSValue *value = [NSValue _methodName:val];\
[argumentBoxingArray addObject:value];\
break;\
}\

                zj_FWD_ARG_STRUCT(CGRect, valueWithCGRect)
                zj_FWD_ARG_STRUCT(CGPoint, valueWithCGPoint)
                zj_FWD_ARG_STRUCT(CGSize, valueWithCGSize)
                zj_FWD_ARG_STRUCT(NSRange, valueWithRange)
                zj_FWD_ARG_STRUCT(CGAffineTransform, valueWithCGAffineTransform)
                zj_FWD_ARG_STRUCT(UIEdgeInsets, valueWithUIEdgeInsets)
                zj_FWD_ARG_STRUCT(UIOffset, valueWithUIOffset)
                zj_FWD_ARG_STRUCT(CGVector, valueWithCGVector)
                
            }
                break;
            case '*': {
                zj_generateError(@"unsupported char* argument", error);
                return nil;
            }
                break;
            case '^': {
                void *value = va_arg(argList, void**);
                zj_pointer *pointerObj = [[zj_pointer alloc] init];
                pointerObj.pointer = value;
                [argumentBoxingArray addObject:pointerObj];
            }
                break;
            case '#': {
                Class value = va_arg(argList, Class);
                [argumentBoxingArray addObject:(id)value];
            }
                break;
            case '@': {
                id value = va_arg(argList, id);
                if (value) {
                    [argumentBoxingArray addObject:value];
                } else {
                    [argumentBoxingArray addObject:[zj_nilObject new]];
                }
            }
                break;
            default: {
                zj_generateError(@"unsupport argument", error);
                return nil;
            }
        }
    }
    return [argumentBoxingArray copy];
};


@implementation NSObject (ZJMsgSend)

+ (id)ZJCallSelector:(SEL)selector error:(NSError * _Nullable __autoreleasing *)error, ... {
    va_list argList;
    va_start(argList, error);
    NSArray *boxingArguments = zj_targetBoxingArguments(argList, [self class], selector, error);
    va_end(argList);
    
    if (!boxingArguments) {
        return nil;
    }
    return zj_targetCallSelectorWithArgumentError(self, selector, boxingArguments, error);
}

+ (id)ZJCallSelectorName:(NSString *)selName error:(NSError * _Nullable __autoreleasing *)error, ... {
    
    va_list argList;
    va_start(argList, error);
    SEL selector = NSSelectorFromString(selName);
    NSArray *boxingArguments = zj_targetBoxingArguments(argList, [self class], selector, error);
    va_end(argList);
    
    if (!boxingArguments) {
        return nil;
    }
    return zj_targetCallSelectorWithArgumentError(self, selector, boxingArguments, error);
}

- (id)ZJCallSelector:(SEL)selector error:(NSError * _Nullable __autoreleasing *)error, ... {
    va_list argList;
    va_start(argList, error);
    NSArray *boxingArguments = zj_targetBoxingArguments(argList, [self class], selector, error);
    va_end(argList);
    if (!boxingArguments) {
        return nil;
    }
    return zj_targetCallSelectorWithArgumentError(self, selector, boxingArguments, error);
}

- (id)ZJCallSelectorName:(NSString *)selName error:(NSError * _Nullable __autoreleasing *)error, ... {
    
    va_list argList;
    va_start(argList, error);
    SEL selector = NSSelectorFromString(selName);
    NSArray *boxingArguments = zj_targetBoxingArguments(argList, [self class], selector, error);
    va_end(argList);
    if (!boxingArguments) {
        return nil;
    }
    return zj_targetCallSelectorWithArgumentError(self, selector, boxingArguments, error);
}

@end

@implementation NSString (ZJMsgSend)

- (id)ZJCallClassSelector:(SEL)selector error:(NSError * __autoreleasing *)error,... {
    Class cls = NSClassFromString(self);
    if (!cls) {
        NSString *errStr = [NSString stringWithFormat:@"unrecognized className (%@)",self];
        zj_generateError(errStr, error);
        return nil;
    }
    va_list argList;
    va_start(argList, error);
    NSArray *boxingArguments = zj_targetBoxingArguments(argList, cls, selector, error);
    va_end(argList);
    if (!boxingArguments) {
        return nil;
    }
    
    return zj_targetCallSelectorWithArgumentError(cls, selector, boxingArguments, error);
}

- (id)ZJCallClassSelectorName:(NSString *)selName error:(NSError * __autoreleasing *)error,... {
    Class cls = NSClassFromString(self);
    if (!cls) {
        NSString *errStr = [NSString stringWithFormat:@"unrecognized className (%@)",self];
        zj_generateError(errStr, error);
        return nil;
    }

    SEL selector = NSSelectorFromString(selName);

    va_list argList;
    va_start(argList, error);
    NSArray *boxingArguments = zj_targetBoxingArguments(argList, cls, selector, error);
    va_end(argList);
    if (!boxingArguments) {
        return nil;
    }
    
    return zj_targetCallSelectorWithArgumentError(cls, selector, boxingArguments, error);
}

- (id)ZJCallClassAllocInitSelector:(SEL)selector error:(NSError * __autoreleasing *)error,... {
    Class cls = NSClassFromString(self);
    if (!cls) {
        NSString *errStr = [NSString stringWithFormat:@"unrecognized className (%@)",self];
        zj_generateError(errStr, error);
        return nil;
    }
    va_list argList;
    va_start(argList, error);
    NSArray* boxingArguments = zj_targetBoxingArguments(argList, cls, selector, error);
    va_end(argList);
    
    if (!boxingArguments) {
        return nil;
    }
    
    id allocObj = [cls alloc];
    return zj_targetCallSelectorWithArgumentError(allocObj, selector, boxingArguments, error);
}

- (id)ZJCallClassAllocInitSelectorName:(NSString *)selName error:(NSError * __autoreleasing *)error,... {
    Class cls = NSClassFromString(self);
    if (!cls) {
        NSString *errStr = [NSString stringWithFormat:@"unrecognized className (%@)",self];
        zj_generateError(errStr, error);
        return nil;
    }
    
    SEL selector = NSSelectorFromString(selName);
    
    va_list argList;
    va_start(argList, error);
    NSArray* boxingArguments = zj_targetBoxingArguments(argList, cls, selector, error);
    va_end(argList);
    
    if (!boxingArguments) {
        return nil;
    }
    
    id allocObj = [cls alloc];
    return zj_targetCallSelectorWithArgumentError(allocObj, selector, boxingArguments, error);
}

@end
