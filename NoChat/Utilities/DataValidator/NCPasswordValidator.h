#import <Foundation/Foundation.h>

@interface NCPasswordValidator : NSObject

@property (nonatomic, assign) NSInteger minLength;
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, assign) BOOL mustContainLetters;
@property (nonatomic, assign) BOOL mustContainNumbers;
@property (nonatomic, assign) BOOL mustContainSpecialCharacters;

- (BOOL)isValidForPassword:(NSString *)password
                 errorCode:(NSInteger *)errorCode
          errorDescription:(NSString **)errorDescription;

- (BOOL)passwordsMatch:(NSString *)password andPasswordConfirmation:(NSString *)passwordConfirmation;

@end
