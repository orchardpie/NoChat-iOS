#import "NCErrors.h"

@implementation NCErrors

- (instancetype)initWithJSONObject:(id)obj
{
    if (self = [super init]) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            self.error = [self errorFromJSONObject:obj];
        } else {
            self.error = nil;
        }
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd]; return nil;
}

- (NSError *)errorFromJSONObject:(NSDictionary *)dictionary
{
    NSDictionary *errors = dictionary[@"errors"];
    if (errors.allKeys.count) {
        NSString *errorMessage = errors[errors.allKeys[0]][0];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorMessage};

        return [NSError errorWithDomain:@"com.nochat.mobile" code:0 userInfo:userInfo];
    } else {
        return nil;
    }
}

@end
