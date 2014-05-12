#import <AddressBook/AddressBook.h>
#import "NCAddressBook.h"

@interface NCAddressBook ()

@property (assign, nonatomic) ABAddressBookRef addressBook;

@end

@implementation NCAddressBook

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

@end
