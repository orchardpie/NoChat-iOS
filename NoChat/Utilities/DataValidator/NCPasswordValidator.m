#import "NCDataValidator.h"
#import "NCPasswordValidator.h"
#import "NSString+NoChat.h"

@implementation NCPasswordValidator

- (id)init
{
    self = [super init];
    
    if (self) {
        _minLength = 0;
        _maxLength = 1000;
        _mustContainLetters = NO;
        _mustContainNumbers = NO;
        _mustContainSpecialCharacters = NO;
    }
    
    return self;
}

- (BOOL)isValidForPassword:(NSString *)password
                 errorCode:(NSInteger *)errorCode
          errorDescription:(NSString **)errorDescription
{
    if (!password || [self isPasswordEmpty:password]) {
        *errorCode = kNCErrorCodeInvalidPassword;
        *errorDescription = kNCErrorEmptyValueMessage;
        return NO;
    }
    
    if ([self isTooLong:password]) {
        *errorCode = kNCErrorCodePasswordTooLong;
        *errorDescription = NSLocalizedString(@"password too long", @"password too long error for NC form field validation");
        return NO;
    }
    
    if ([self isTooShort:password]) {
        *errorCode = kNCErrorCodePasswordTooShort;
        *errorDescription = NSLocalizedString(@"password too short", @"password too short error for NC form field validation");
        return NO;
    }
    
    if (self.mustContainLetters && ![self containsLetters:password]) {
        *errorCode = kNCErrorCodeInvalidPassword;
        *errorDescription = NSLocalizedString(@"password must contain letters", @"password must contain letters error for NC form field validation");
        return NO;
    }
    
    return YES;
}

- (BOOL)passwordsMatch:(NSString *)password
andPasswordConfirmation:(NSString *)passwordConfirmation
{
    return [password isEqualToString:passwordConfirmation];
}


#pragma mark -
#pragma mark - Private instance methods

- (BOOL)isPasswordEmpty:(NSString *)password
{
    return [password nc_isEmpty];
}

- (BOOL)isTooLong:(NSString *)password
{
    return password.length > self.maxLength;
}

- (BOOL)isTooShort:(NSString *)password
{
    return password.length < self.minLength;
}

- (BOOL)containsLetters:(NSString *)password
{
    return [password nc_containsLetters];
}

- (BOOL)containsNumbers:(NSString *)password
{
    return [password nc_containsNumbers];
}

- (BOOL)containsSpecialCharacters:(NSString *)password
{
    return [password nc_containsSpecialCharacters];
}

@end
