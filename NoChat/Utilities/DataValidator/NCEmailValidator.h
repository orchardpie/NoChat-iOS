#import <Foundation/Foundation.h>

@interface NCEmailValidator : NSObject

- (BOOL)isValidForEmail:(NSString *)email
              errorCode:(NSInteger *)errorCode
       errorDescription:(NSString **)errorDescription;

@end
