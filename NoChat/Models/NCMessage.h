#import <Foundation/Foundation.h>
#import "NCWebService.h"

@interface NCMessage : NSObject

@property (strong, nonatomic) NSNumber *messageId;
@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSString *timeSavedDescription;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *receiverEmail;
@property (strong, nonatomic) NSString *disposition;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)saveWithSuccess:(void(^)())success
         failure:(WebServiceError)failure;

@end
