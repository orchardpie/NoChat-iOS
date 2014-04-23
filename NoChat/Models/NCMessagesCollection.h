#import <Foundation/Foundation.h>

@interface NCMessagesCollection : NSObject

- (instancetype)initWithLocation:(NSString *)location
                        messages:(NSArray *)messages;
- (void)fetchWithSuccess:(void(^)())success
                 failure:(void(^)(NSError *error))failure;

@end

@interface NCMessagesCollection (CollectionInterface)

- (NSUInteger)count;

@end