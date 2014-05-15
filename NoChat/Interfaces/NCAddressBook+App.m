#import <AddressBook/AddressBook.h>
#import "NCAddressBook.h"
#import "NCContact.h"


#pragma mark - NCAddressBookImpl

@interface NCAddressBookImpl : NSObject

@property (assign, nonatomic) ABAddressBookRef addressBook;

@end

@implementation NCAddressBookImpl
@end

#pragma mark - NCAddressBook+App

@interface NCAddressBook (AppPrivate)

@property (nonatomic, strong) NCAddressBookImpl *impl;

@end

@implementation NCAddressBook (App)

- (void)dealloc {
    if (self.implObj.addressBook) {
        CFRelease(self.implObj.addressBook);
    }
}

- (void)checkAccess:(void(^)(BOOL, NSError *))completion
{
    CFErrorRef cfError = NULL;

    if (!self.implObj.addressBook) {
        self.implObj.addressBook = ABAddressBookCreateWithOptions(0, &cfError);
    }

    if (cfError) {
        completion(NO, (__bridge_transfer NSError *)cfError);
    } else {
        ABAddressBookRequestAccessWithCompletion(self.implObj.addressBook, ^(bool granted, CFErrorRef cfError) {
            // ABAddressBookRequestAccessWithCompletion responds on a thread other than the main thread.
            // Push the response back to the main thread, so the caller (generally the UI) need not worry
            // about what thread the response is on.
            dispatch_sync(dispatch_get_main_queue(), ^{
                completion(granted, nil);
            });
        });
    }
}

- (NSArray *)allContacts
{
    CFArrayRef contactsFromAddressBook = ABAddressBookCopyArrayOfAllPeople(self.impl.addressBook);
    CFIndex contactsCount = CFArrayGetCount(contactsFromAddressBook);
    NSMutableArray *contacts = [NSMutableArray array];

    for (int i = 0; i < contactsCount; i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(contactsFromAddressBook, i);
        NSString *firstName = (__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSArray *emails = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonEmailProperty));

        NCContact *contact = [[NCContact alloc] initWithFirstName:firstName lastName:lastName emails:emails];
        [contacts addObject:contact];
    }

    CFRelease(contactsFromAddressBook);
    return contacts;
}


- (NCAddressBookImpl *)implObj
{
    if (!self.impl) {
        self.impl = [[NCAddressBookImpl alloc] init];
    }
    return self.impl;
}

@end
