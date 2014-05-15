#import <Foundation/Foundation.h>

@interface NCContact : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSArray *emails;

- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                           emails:(NSArray *)emails;
- (NSString *)fullName;

@end
