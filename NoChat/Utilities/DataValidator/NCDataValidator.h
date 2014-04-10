#import <Foundation/Foundation.h>

@class NCPasswordValidator;

#import <Foundation/Foundation.h>

/**
 `NCDataValidator` is a set of convenience methods for reading/writing files from/to disk
 */

#define kNCErrorDomain                          @"com.nochat.mobile"
#define kNCErrorCodeInvalidEmail                5001
#define kNCErrorCodeInvalidPassword             5002
#define kNCErrorCodePasswordMismatch            5003
#define kNCErrorCodePasswordTooShort            5004
#define kNCErrorCodePasswordTooLong             5005

#define kNCErrorEmptyValueMessage NSLocalizedString(@"empty value", @"empty value error for form field validation");
#define kNCErrorInvalidValueMessage NSLocalizedString(@"invalid value", @"invalid value error for form field validation");

@interface NCDataValidator : NSObject

/**
 Validates an email string, and returns an NSError if one occurs

 @param email An email string

 @return An NSError, if one occurs
 */
+ (NSError *)validateEmail:(NSString *)email;

/**
 Validates an email string and password string, and returns an NSError if one occurs

 @param email An email string
 @param password A password string
 @param passwordValidator An optional, custom password formatter, allowing you to set password requirements (e.g. length, special characters)

 @return An NSError, if one occurs
 */
+ (NSError *)validateEmail:(NSString *)email
               andPassword:(NSString *)password
         passwordValidator:(NCPasswordValidator *)passwordValidator;

/**
 Validates an email string, password string, and password confirmation string, and returns an NSError if one occurs

 @param email An email string
 @param password A password string
 @param passwordConfirmation A password confirmation string
 @param passwordValidator An optional, custom password formatter, allowing you to set password requirements (e.g. length, special characters)

 @return An NSError, if one occurs
 */
+ (NSError *)validateEmail:(NSString *)email
               andPassword:(NSString *)password
  withPasswordConfirmation:(NSString *)passwordConfirmation
         passwordValidator:(NCPasswordValidator *)passwordValidator;

@end

