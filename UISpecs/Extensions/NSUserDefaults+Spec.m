#import "NSUserDefaults+Spec.h"

static NSMutableDictionary *__standardUserDefaultsDict;
static NSUserDefaults *__standardUserDefaults;

@implementation NSUserDefaults (Spec)

+ (void)beforeEach {
    [__standardUserDefaultsDict removeAllObjects];
}

+ (instancetype)standardUserDefaults
{
    if (!__standardUserDefaults) {
        __standardUserDefaults = [[NSUserDefaults alloc] init];
        __standardUserDefaultsDict = [NSMutableDictionary dictionary];
    }
    return __standardUserDefaults;
}

+ (NSMutableDictionary *)standardUserDefaultsDict
{
    return __standardUserDefaultsDict;
}

+ (void)setStandardUserDefaultsDict:(NSMutableDictionary *)userDefaults
{
    __standardUserDefaultsDict = userDefaults;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (BOOL)synchronize
{
    return YES;
}

- (void)setObject:(id)value forKey:(NSString *)defaultName
{
    [self.class.standardUserDefaultsDict setObject:value forKey:defaultName];
}

- (id)objectForKey:(NSString *)defaultName
{
    return [self.class.standardUserDefaultsDict objectForKey:defaultName];
}

- (void)removeObjectForKey:(NSString *)defaultName
{
    [self.class.standardUserDefaultsDict removeObjectForKey:defaultName];
}

#pragma clang diagnostic pop

@end
