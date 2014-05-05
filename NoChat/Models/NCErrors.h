#import <Foundation/Foundation.h>

@interface NCErrors : NSObject

@property (strong, nonatomic) NSError *error;

- (instancetype)initWithJSONObject:(id)obj;

@end
