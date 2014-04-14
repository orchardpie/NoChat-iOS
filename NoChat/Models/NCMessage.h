#import <Foundation/Foundation.h>
#import "NCWebService.h"

@interface NCMessage : NSObject

@property (strong, nonatomic) NSNumber *time_saved;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *receiver_email;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)saveWithSuccess:(void(^)())success
          serverFailure:(WebServiceServerFailure)serverFailure
         networkFailure:(WebServiceNetworkFailure)networkFailure;

@end
