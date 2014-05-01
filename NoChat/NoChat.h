#import <Foundation/Foundation.h>
#import "NCWebService.h"

@class NCAnalytics;

@interface NoChat : NSObject

@property (strong, nonatomic, readonly) NCWebService *webService;
@property (strong, nonatomic, readonly) NCAnalytics *analytics;

@end

extern void NCParameterAssert(id parameter);
extern NoChat *noChat;