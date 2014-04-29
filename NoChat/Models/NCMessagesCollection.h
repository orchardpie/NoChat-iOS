#import <Foundation/Foundation.h>

@interface NCMessagesCollection : NSObject

- (instancetype)initWithMessagesDict:(NSDictionary *)messagesDict;
- (void)fetchWithSuccess:(void(^)())success
                 failure:(void(^)(NSError *error))failure;

@end

@interface NCMessagesCollection (CollectionInterface)

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;

@end
