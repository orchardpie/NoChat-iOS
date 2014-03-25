#import <Foundation/Foundation.h>

@class NCUser;

typedef void(^UserLoginCompletion)(NCUser *user, NSError *error);

@interface NCUser : NSObject

@property (strong, nonatomic) NSString *name;

+ (void)logInWithEmail:(NSString *)email andPassword:(NSString *)password completion:(UserLoginCompletion)completion;
- (instancetype)initWithDictionary:(NSDictionary *)userDict;

@end
