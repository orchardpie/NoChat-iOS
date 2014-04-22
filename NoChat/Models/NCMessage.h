#import <Foundation/Foundation.h>
#import "NCWebService.h"

@interface NCMessage : NSObject

@property (strong, nonatomic) NSNumber *messageId;
@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSNumber *timeSaved;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *receiverEmail;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)saveWithSuccess:(void(^)())success
         failure:(WebServiceError)failure;

@end
