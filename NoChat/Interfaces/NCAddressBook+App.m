#import <AddressBook/AddressBook.h>
#import "NCAddressBook.h"
#import "NCContact.h"


#pragma mark - NCAddressBookImpl

@interface NCAddressBookImpl : NSObject

@property (assign, nonatomic) ABAddressBookRef addressBook;

@end

@implementation NCAddressBookImpl

- (void)dealloc {
    if (self.addressBook) {
        CFRelease(self.addressBook);
    }
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

- (NSArray *)allContacts
{
    CFArrayRef contactsFromAddressBook = ABAddressBookCopyArrayOfAllPeopleInSource(self.addressBook, ABAddressBookCopyDefaultSource(self.addressBook));
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

@end

#pragma mark - NCAddressBook+App

@interface NCAddressBook (AppPrivate)

@property (nonatomic, strong) NCAddressBookImpl *impl;

@end

@implementation NCAddressBook (AppImplementation)

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self.impl];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    if (!self.impl) {
        self.impl = [[NCAddressBookImpl alloc] init];
    }

    NSMethodSignature *ms = [super methodSignatureForSelector:selector];
    if (!ms) {
        ms = [self.impl methodSignatureForSelector:selector];
    }
    return ms;
}

@end
