#import "NCDataValidator.h"
#import "NCEmailValidator.h"
#import "NSString+NoChat.h"

@implementation NCEmailValidator

- (BOOL)isValidForEmail:(NSString *)email
              errorCode:(NSInteger *)errorCode
       errorDescription:(NSString **)errorDescription
{
    if ([self isEmailEmpty:email]) {
        *errorCode = kNCErrorCodeInvalidEmail;
        *errorDescription = kNCErrorEmptyValueMessage;
        return NO;
    }
    
    if (![self isEmailValid:email]) {
        *errorCode = kNCErrorCodeInvalidEmail;
        *errorDescription = kNCErrorInvalidValueMessage
        return NO;
    }
    
    return YES;
}


#pragma mark -
#pragma mark - Private instance methods

- (BOOL)isEmailEmpty:(NSString *)email
{
    return [email nc_isEmpty];
}

- (BOOL)isEmailValid:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end