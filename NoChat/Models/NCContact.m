#import "NCContact.h"

@implementation NCContact

- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                           emails:(NSArray *)emails
{
    if (self = [super init]) {
        self.firstName = firstName;
        self.lastName = lastName;
        self.emails = emails;
    }
    return self;
}

@end
