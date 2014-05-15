#import "NCAddressBook.h"

@class NCContact;

@interface NCAddressBook (Spec)

- (void)respondWithAccess:(BOOL)hasAccess error:(NSError *)error;
- (void)addContact:(NCContact *)contact;
- (void)removeAllContacts;

@end