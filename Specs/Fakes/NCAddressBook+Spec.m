#import "NCAddressBook+Spec.h"
#import "NCContact.h"
#import "objc/runtime.h"

#pragma mark - NCAddressBookImpl

@interface NCAddressBookImpl : NSObject

@property (nonatomic, copy) void (^accessBlock)(BOOL, NSError *);
@property (nonatomic, strong) NSMutableArray *fakeContacts;

@end

@implementation NCAddressBookImpl

- (instancetype)init
{
    if (self = [super init]) {
        self.fakeContacts = [NSMutableArray array];
    }
    return self;
}

@end


#pragma mark - NCAddressBook+Spec

@interface NCAddressBook (SpecPrivate)

@property (nonatomic, strong) NCAddressBookImpl *impl;

@end

@implementation NCAddressBook (Spec)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (void)checkAccess:(void(^)(BOOL, NSError *))completion
{
    self.implObj.accessBlock = completion;
}

#pragma clang diagnostic pop

- (void)respondWithAccess:(BOOL)hasAccess error:(NSError *)error
{
    if (!self.implObj.accessBlock) {
        @throw @"Responding to Address Book access request, but there is no request";
    }
    self.implObj.accessBlock(hasAccess, error);
    self.implObj.accessBlock = nil;
}

- (NSMutableArray *)allContacts {
    return self.implObj.fakeContacts;
}

- (void)addContact:(NCContact *)contact
{
    [self.implObj.fakeContacts addObject:contact];
}

- (NCAddressBookImpl *)implObj
{
    if (!self.impl) {
        self.impl = [[NCAddressBookImpl alloc] init];
    }
    return self.impl;
}

@end