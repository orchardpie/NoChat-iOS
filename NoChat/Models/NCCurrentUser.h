#import <Foundation/Foundation.h>

@class NCCurrentUser;

@interface NCCurrentUser : NSObject

@property (strong, nonatomic) NSString *name;

- (BOOL)saveCredentialsWithEmail:(NSString *)email andPassword:(NSString *)password;

@end
