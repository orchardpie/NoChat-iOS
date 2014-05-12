#import "NCAddressBook.h"

@interface NCAddressBook (Spec)

- (void)respondWithAccess:(BOOL)hasAccess error:(NSError *)error;

@end