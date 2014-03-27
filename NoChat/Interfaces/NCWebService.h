#import "AFHTTPSessionManager.h"

@interface NCWebService : AFHTTPSessionManager

- (void)setCredential:(NSURLCredential *)credential;

- (BOOL)hasCredential;

@end
