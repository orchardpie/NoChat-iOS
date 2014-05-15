#import <Foundation/Foundation.h>

@interface NCAddressBook : NSObject

- (NSArray *)contacts;

@end

@interface NCAddressBook (QuietCompiler)

- (void)checkAccess:(void(^)(BOOL, NSError *))completion;

@end