#import "NCDataValidator.h"
#import "NCEmailValidator.h"
#import "NCPasswordValidator.h"

@implementation NCDataValidator

+ (NSError *)validateEmail:(NSString *)email
{
    NSError *error = nil;

    [NCDataValidator validateEmail:email withError:&error];

    return error;
}

+ (NSError *)validateEmail:(NSString *)email
               andPassword:(NSString *)password
         passwordValidator:(NCPasswordValidator *)passwordValidator
{
    NSError *error = nil;

    [NCDataValidator validateEmail:email withError:&error];

    if (error)
        return error;

    [NCDataValidator validatePassword:password withPasswordValidator:passwordValidator andError:&error];

    return error;
}

+ (NSError *)validateEmail:(NSString *)email
               andPassword:(NSString *)password
  withPasswordConfirmation:(NSString *)passwordConfirmation
         passwordValidator:(NCPasswordValidator *)passwordValidator
{
    NSError *error = nil;

    [NCDataValidator validateEmail:email withError:&error];

    if (error)
        return error;

    [NCDataValidator validatePassword:password withPasswordValidator:passwordValidator andError:&error];

    if (error)
        return error;

    [NCDataValidator validatePasswordMatchesPasswordConfirmation:password andPasswordConfirmation:passwordConfirmation withError:&error];

    return error;
}


#pragma mark -
#pragma mark - Private individual form field validator methods

+ (void)validateEmail:(NSString *)email withError:(NSError **)error
{
    NCEmailValidator *emailValidator = [[NCEmailValidator alloc] init];

    NSInteger errorCode;
    NSString *errorDescription = @"";

    if (![emailValidator isValidForEmail:email errorCode:&errorCode errorDescription:&errorDescription]) {
        NSError *emailError = [NSError errorWithDomain:kNCErrorDomain code:errorCode userInfo:@{ @"message": errorDescription}];
        *error = emailError;
    }
}

+ (void)validatePassword:(NSString *)password withPasswordValidator:(NCPasswordValidator *)passwordValidator andError:(NSError **)error
{
    if (!passwordValidator)
        passwordValidator = [[NCPasswordValidator alloc] init];

    NSInteger errorCode;
    NSString *errorDescription = @"";

    if (![passwordValidator isValidForPassword:password errorCode:&errorCode errorDescription:&errorDescription]) {
        NSError *passwordError = [NSError errorWithDomain:kNCErrorDomain code:errorCode userInfo:@{ @"message": errorDescription}];
        *error = passwordError;
    }
}

+ (void)validatePasswordMatchesPasswordConfirmation:(NSString *)password andPasswordConfirmation:(NSString *)passwordConfirmation withError:(NSError **)error
{
    NCPasswordValidator *passwordValidator = [[NCPasswordValidator alloc] init];
    NSString *errorDescription = @"";

    if (![passwordValidator passwordsMatch:password andPasswordConfirmation:passwordConfirmation]) {
        NSError *passwordError = [NSError errorWithDomain:kNCErrorDomain code:kNCErrorCodePasswordMismatch userInfo:@{ @"message": errorDescription}];
        *error = passwordError;
    }
}

@end
