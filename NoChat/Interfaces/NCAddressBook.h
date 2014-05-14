#import <Foundation/Foundation.h>

@interface NCAddressBook : NSObject

@property (strong, nonatomic) NSArray *contacts;

- (void)checkAccess:(void(^)(BOOL, NSError *))completion;

@end
