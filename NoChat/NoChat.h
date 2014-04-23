#import <Foundation/Foundation.h>
#import "NCWebService.h"

@interface NoChat : NSObject

@property (strong, nonatomic, readonly) NCWebService *webService;

- (void)invalidateCurrentUser;

@end

extern void NCParameterAssert(id parameter);
extern NoChat *noChat;

