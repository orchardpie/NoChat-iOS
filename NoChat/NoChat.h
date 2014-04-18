#import <Foundation/Foundation.h>
#import "NCWebService.h"

@protocol NoChatDelegate <NSObject>

- (void)userDidSwitchToLogin;

@end

@interface NoChat : NSObject

@property (strong, nonatomic, readonly) NCWebService *webService;

- (void)invalidateCurrentUser;

@end

extern NoChat *noChat;
