#import <Foundation/Foundation.h>

@interface NCMessagesCollection : NSObject

- (instancetype)initWithLocation:(NSString *)location
                        messages:(NSArray *)messages;

@end

@interface NCMessagesCollection (CollectionInterface)

- (NSUInteger)count;

@end