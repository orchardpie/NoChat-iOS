#import <Foundation/Foundation.h>

@class NCMessage;

@interface NCMessagesCollection : NSObject

- (instancetype)initWithMessagesDict:(NSDictionary *)messagesDict;
- (void)fetchWithSuccess:(void(^)())success
                 failure:(void(^)(NSError *error))failure;
- (void)createMessageWithParameters:(NSDictionary *)parameters
                            success:(void(^)(NCMessage *))success
                            failure:(void(^)(NSError *))failure;

@end

@interface NCMessagesCollection (CollectionInterface)

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;

@end
