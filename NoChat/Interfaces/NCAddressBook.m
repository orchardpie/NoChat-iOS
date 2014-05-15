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
    NSArray *filteredContacts = [self.allContacts filteredArrayUsingPredicate:filterByEmail];

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName"
                                                                     ascending:YES
                                                                      selector:@selector(localizedCaseInsensitiveCompare:)];
    return [filteredContacts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

@end
