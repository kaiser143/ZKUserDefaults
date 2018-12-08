//
//  ZKUserDefaults.m
//  NN
//
//  Created by Kaiser on 2018/12/6.
//  Copyright © 2018 zhangkai. All rights reserved.
//

#import "ZKUserDefaults.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, TypeEncodings) {
    Char = 'c',
    Bool = 'B',
    Short = 's',
    Int = 'i',
    Long = 'l',
    LongLong = 'q',
    UnsignedChar = 'C',
    UnsignedShort = 'S',
    UnsignedInt = 'I',
    UnsignedLong = 'L',
    UnsignedLongLong = 'Q',
    Float = 'f',
    Double = 'd',
    Object = '@'
};


@interface ZKUserDefaults ()

@property (nonatomic, strong) NSMutableDictionary *mapping;
@property (nonatomic, strong) NSUserDefaults *standardUserDefaults;

- (NSString *)defaultsKeyForSelector:(SEL)selector;

@end

NS_INLINE long long longLongGetter(ZKUserDefaults *self, SEL _cmd) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    return [[self.standardUserDefaults objectForKey:key] longLongValue];
}

NS_INLINE void longLongSetter(ZKUserDefaults *self, SEL _cmd, long long value) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    NSNumber *object = [NSNumber numberWithLongLong:value];
    [self.standardUserDefaults setObject:object forKey:key];
}

NS_INLINE BOOL boolGetter(ZKUserDefaults *self, SEL _cmd) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    return [self.standardUserDefaults boolForKey:key];
}

NS_INLINE void boolSetter(ZKUserDefaults *self, SEL _cmd, BOOL value) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    [self.standardUserDefaults setBool:value forKey:key];
}

NS_INLINE int integerGetter(ZKUserDefaults *self, SEL _cmd) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    return (int)[self.standardUserDefaults integerForKey:key];
}

NS_INLINE void integerSetter(ZKUserDefaults *self, SEL _cmd, int value) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    [self.standardUserDefaults setInteger:value forKey:key];
}

NS_INLINE float floatGetter(ZKUserDefaults *self, SEL _cmd) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    return [self.standardUserDefaults floatForKey:key];
}

NS_INLINE void floatSetter(ZKUserDefaults *self, SEL _cmd, float value) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    [self.standardUserDefaults setFloat:value forKey:key];
}

NS_INLINE double doubleGetter(ZKUserDefaults *self, SEL _cmd) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    return [self.standardUserDefaults doubleForKey:key];
}

NS_INLINE void doubleSetter(ZKUserDefaults *self, SEL _cmd, double value) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    [self.standardUserDefaults setDouble:value forKey:key];
}

NS_INLINE id objectGetter(ZKUserDefaults *self, SEL _cmd) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    return [self.standardUserDefaults objectForKey:key];
}

NS_INLINE void objectSetter(ZKUserDefaults *self, SEL _cmd, id object) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    if (object) {
        [self.standardUserDefaults setObject:object forKey:key];
    } else {
        [self.standardUserDefaults removeObjectForKey:key];
    }
    [self.standardUserDefaults synchronize];
}

@implementation ZKUserDefaults

+ (instancetype)manager {
    NSString *key = NSStringFromClass(self);
    static NSMutableDictionary *dictionary = nil;
    if (!dictionary) dictionary = @{}.mutableCopy;
    
    id instance = dictionary[key];
    if (!instance) {
        instance = [[self alloc] init];
        dictionary[key] = instance;
    }
    
    return instance;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
#pragma GCC diagnostic ignored "-Warc-performSelector-leaks"

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    SEL setupDefaultSEL = NSSelectorFromString([NSString stringWithFormat:@"%@Defaults", @"setup"]);
    if ([self respondsToSelector:setupDefaultSEL]) {
        NSDictionary *defaults = [self performSelector:setupDefaultSEL];
        NSMutableDictionary *mutableDefaults = [NSMutableDictionary dictionaryWithCapacity:[defaults count]];
        for (NSString *key in defaults) {
            id value = [defaults objectForKey:key];
            NSString *transformedKey = [self _transformKey:key];
            transformedKey = [NSString stringWithFormat:@"%@_%@",NSStringFromClass(self.class),transformedKey];
            [mutableDefaults setObject:value forKey:transformedKey];
        }
        [self.standardUserDefaults registerDefaults:mutableDefaults];
        [self.standardUserDefaults synchronize];
    }
    
    [self generateAccessorMethods];
    
    return self;
}

#pragma GCC diagnostic pop

#pragma mark - Public methods

- (void)removeAllItems {
    NSArray *keys = [[NSSet setWithArray:self.mapping.allValues] allObjects];
    for (NSString *key in keys) [self.standardUserDefaults removeObjectForKey:key];
    [self.standardUserDefaults synchronize];
}

#pragma mark - Private methods

- (NSString *)defaultsKeyForPropertyNamed:(char const *)propertyName {
    NSString *key = [NSString stringWithFormat:@"%s", propertyName];
    key =  [self _transformKey:key];
    return [NSString stringWithFormat:@"%@_%@",NSStringFromClass(self.class),key];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
#pragma GCC diagnostic ignored "-Warc-performSelector-leaks"

- (NSString *)_transformKey:(NSString *)key {
    if ([self respondsToSelector:@selector(transformKey:)]) {
        return [self performSelector:@selector(transformKey:) withObject:key];
    }
    
    return key;
}

- (NSString *)_suiteName {
    if ([self respondsToSelector:@selector(suitName)]) {
        return [self performSelector:@selector(suitName)];
    }
    
    if ([self respondsToSelector:@selector(suiteName)]) {
        return [self performSelector:@selector(suiteName)];
    }
    
    return nil;
}

#pragma GCC diagnostic pop

- (NSString *)defaultsKeyForSelector:(SEL)selector {
    return [self.mapping objectForKey:NSStringFromSelector(selector)];
}

- (void)generateAccessorMethods {
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    self.mapping = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < count; ++i) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        const char *attributes = property_getAttributes(property);
        
        char *getter = strstr(attributes, ",G");
        if (getter) {
            getter = strdup(getter + 2);
            getter = strsep(&getter, ",");
        } else {
            getter = strdup(name);
        }
        SEL getterSel = sel_registerName(getter);
        free(getter);
        
        char *setter = strstr(attributes, ",S");
        if (setter) {
            setter = strdup(setter + 2);
            setter = strsep(&setter, ",");
        } else {
            asprintf(&setter, "set%c%s:", toupper(name[0]), name + 1);
        }
        SEL setterSel = sel_registerName(setter);
        free(setter);
        
        NSString *key = [self defaultsKeyForPropertyNamed:name];
        [self.mapping setValue:key forKey:NSStringFromSelector(getterSel)];
        [self.mapping setValue:key forKey:NSStringFromSelector(setterSel)];
        
        IMP getterImp = NULL;
        IMP setterImp = NULL;
        char type = attributes[1];
        switch (type) {
            case Short:
            case Long:
            case LongLong:
            case UnsignedChar:
            case UnsignedShort:
            case UnsignedInt:
            case UnsignedLong:
            case UnsignedLongLong:
                getterImp = (IMP)longLongGetter;
                setterImp = (IMP)longLongSetter;
                break;
                
            case Bool:
            case Char:
                getterImp = (IMP)boolGetter;
                setterImp = (IMP)boolSetter;
                break;
                
            case Int:
                getterImp = (IMP)integerGetter;
                setterImp = (IMP)integerSetter;
                break;
                
            case Float:
                getterImp = (IMP)floatGetter;
                setterImp = (IMP)floatSetter;
                break;
                
            case Double:
                getterImp = (IMP)doubleGetter;
                setterImp = (IMP)doubleSetter;
                break;
                
            case Object:
                getterImp = (IMP)objectGetter;
                setterImp = (IMP)objectSetter;
                break;
                
            default:
                free(properties);
                [NSException raise:NSInternalInconsistencyException format:@"Unsupported type of property \"%s\" in class %@", name, self];
                break;
        }
        
        char types[5];
        
        snprintf(types, 4, "%c@:", type);
        class_addMethod([self class], getterSel, getterImp, types);
        
        snprintf(types, 5, "v@:%c", type);
        class_addMethod([self class], setterSel, setterImp, types);
    }
    
    free(properties);
}

#pragma mark - getters and setters

- (NSUserDefaults *)standardUserDefaults {
    if (!_standardUserDefaults) {
        NSString *suteName = nil;
        if ([NSUserDefaults instancesRespondToSelector:@selector(initWithSuiteName:)]) {
            suteName = [self _suiteName];
        }
        
        if (suteName.length > 0) {
            _standardUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:suteName];
        } else {
            _standardUserDefaults = [NSUserDefaults standardUserDefaults];
        }
    }
    
    return _standardUserDefaults;
}

@end
