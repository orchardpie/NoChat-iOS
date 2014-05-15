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

- (NSString *)fullName
{
    if (self.firstName && self.lastName) {
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    } else if (self.firstName) {
        return self.firstName;
    } else if (self.lastName) {
        return self.lastName;
    } else {
        return self.emails.firstObject;
    }
}

@end
