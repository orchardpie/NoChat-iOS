#import <Foundation/Foundation.h>
#import "NCWebService.h"

@protocol NoChatDelegate <NSObject>

- (void)userDidSwitchToLogin;

@end

@interface NoChat : NSObject

@property (strong, nonatomic, readonly) NCWebService *webService;

- (void)invalidateCurrentUser;

- (instancetype)initWithDelegate:(id)delegate;

@end

extern NoChat *noChat;
