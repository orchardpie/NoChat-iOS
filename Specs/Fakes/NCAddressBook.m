#import "NCAddressBook.h"

@interface NCAddressBook ()

@property (nonatomic, copy) void (^accessBlock)(BOOL, NSError *);

@end

@implementation NCAddressBook

- (void)checkAccess:(void(^)(BOOL, NSError *))completion
{
    self.accessBlock = completion;
}

- (void)respondWithAccess:(BOOL)hasAccess error:(NSError *)error
{
    if (!self.accessBlock) {
        @throw @"Responding to Address Book access request, but there is no request";
    }
    self.accessBlock(hasAccess, error);
    self.accessBlock = nil;
}

@end