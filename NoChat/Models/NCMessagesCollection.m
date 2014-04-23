#import "NCMessagesCollection.h"

@interface NCMessagesCollection ()

@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSArray *messages;

@end

@implementation NCMessagesCollection

- (instancetype)initWithLocation:(NSString *)location
                        messages:(NSArray *)messages
{
    NCParameterAssert(location);

    if (self = [super init]) {
        self.location = location;
        self.messages = messages;
    }
    return self;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [anInvocation invokeWithTarget:self.messages];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [self.messages methodSignatureForSelector:selector];
    }
    return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [super respondsToSelector:aSelector] || [self.messages respondsToSelector:aSelector];
}

@end
