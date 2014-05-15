#import "NCAddressBook+Spec.h"
#import "NCContact.h"
#import "objc/runtime.h"

#pragma mark - NCAddressBookImpl

@interface NCAddressBookImpl : NSObject

@property (nonatomic, copy) void (^accessBlock)(BOOL, NSError *);
@property (nonatomic, strong) NSMutableArray *fakeContacts;

- (void)checkAccess:(void(^)(BOOL, NSError *))completion;
- (void)respondWithAccess:(BOOL)hasAccess error:(NSError *)error;
- (void)addContact:(NCContact *)contact;

@end

@implementation NCAddressBookImpl

- (instancetype)init
{
    if (self = [super init]) {
        self.fakeContacts = [NSMutableArray array];
    }
    return self;
}

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

- (NSMutableArray *)allContacts {
    return self.fakeContacts;
}

- (void)addContact:(NCContact *)contact
{
    [self.fakeContacts addObject:contact];
}

- (void)removeAllContacts
{
    [self.fakeContacts removeAllObjects];
}

@end


#pragma mark - NCAddressBook+Spec

@interface NCAddressBook (SpecPrivate)

@property (nonatomic, strong) NCAddressBookImpl *impl;

@end

@implementation NCAddressBook (SpecImplementation)

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