#import "NCWebService+Spec.h"

static BOOL __hasCredential;

@implementation NCWebService (Spec)

+ (void)setHasCredentialTo:(BOOL)hasCredential
{
    __hasCredential = hasCredential;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (BOOL)hasCredential
{
    return __hasCredential;
}

@end
