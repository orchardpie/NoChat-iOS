#import <Foundation/Foundation.h>

@interface NCAddressBook : NSObject

- (void)checkAccess:(void(^)(BOOL, NSError *))completion;

@end
