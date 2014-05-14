#import <AddressBook/AddressBook.h>
#import "NCAddressBook.h"
#import "NCContact.h"

@interface NCAddressBook ()

@property (assign, nonatomic) ABAddressBookRef addressBook;

@end

@implementation NCAddressBook

- (void)dealloc {
    if (self.addressBook) {
        CFRelease(self.addressBook);
    }
}

- (NSArray *)contacts
{
    return [self parseContactsFromAddressBook];
}

- (void)checkAccess:(void(^)(BOOL, NSError *))completion
{
    CFErrorRef cfError = NULL;

    if (!self.addressBook) {
        self.addressBook = ABAddressBookCreateWithOptions(0, &cfError);
    }

    if (cfError) {
        completion(NO, (__bridge_transfer NSError *)cfError);
    } else {
        ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef cfError) {
            // ABAddressBookRequestAccessWithCompletion responds on a thread other than the main thread.
            // Push the response back to the main thread, so the caller (generally the UI) need not worry
            // about what thread the response is on.
            dispatch_sync(dispatch_get_main_queue(), ^{
                completion(granted, nil);
            });
        });
    }
}

#pragma mark - Private interface

- (NSArray *)parseContactsFromAddressBook
{
    CFArrayRef contactsFromAddressBook = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    CFIndex contactsCount = CFArrayGetCount(contactsFromAddressBook);
    NSMutableArray *contacts = [NSMutableArray array];

    for (int i = 0; i < contactsCount; i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(contactsFromAddressBook, i);
        NSString *firstName = (__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSArray *emails = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonEmailProperty));

        NCContact *contact = [[NCContact alloc] initWithFirstName:firstName lastName:lastName emails:emails];
        [contacts addObject:contact];
        CFRelease(person);
    }

    CFRelease(contactsFromAddressBook);
    return contacts;
}

@end
