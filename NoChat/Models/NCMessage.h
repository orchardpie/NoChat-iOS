#import <Foundation/Foundation.h>

@interface NCMessage : NSObject

@property (strong, nonatomic) NSNumber *time_saved;
@property (strong, nonatomic) NSString *disposition;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
