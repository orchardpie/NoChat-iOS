#import <Foundation/Foundation.h>
#import "NCWebService.h"

@interface NoChat : NSObject

@property (strong, nonatomic, readonly) NCWebService *webService;

@end

extern NoChat *noChat;
