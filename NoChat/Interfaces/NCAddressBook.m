#import "NCAddressBook.h"
#import "NCContact.h"

@class NCAddressBookImpl;

@interface NCAddressBook ()

@property (nonatomic, strong) NCAddressBookImpl *impl;

@end

@interface NCAddressBook (Virtual)

- (NSArray *)allContacts;

@end

@implementation NCAddressBook

- (NSArray *)contacts
{
    NSPredicate *filterByEmail = [NSPredicate predicateWithFormat:@"emails.@count > 0"];
    return [self.allContacts filteredArrayUsingPredicate:filterByEmail];
}

@end
