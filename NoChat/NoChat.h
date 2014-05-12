#import <Foundation/Foundation.h>

@class NCAnalytics, NCWebService, NCAddressBook;

@interface NoChat : NSObject

@property (strong, nonatomic, readonly) NCWebService *webService;
@property (strong, nonatomic, readonly) NCAnalytics *analytics;
@property (strong, nonatomic, readonly) NCAddressBook *addressBook;

@end

extern void NCParameterAssert(id parameter);
extern NoChat *noChat;