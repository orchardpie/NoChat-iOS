#import "NCMessagesCollection.h"
#import "NoChat.h"
#import "NCMessage.h"

@interface NCMessagesCollection () <NSCoding>

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

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.location = [decoder decodeObjectForKey:@"location"];
    self.messages = [decoder decodeObjectForKey:@"messages"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeObject:self.messages forKey:@"messages"];
}

- (void)fetchWithSuccess:(void(^)())success
                 failure:(void(^)(NSError *error))failure
{
    [noChat.webService GET:self.location parameters:nil completion:^(id responseBody) {
        [self setMessagesFromResponse:responseBody];
        if (success) { success(); }

    } invalid:nil error:failure];
}

- (void)setMessagesFromResponse:(id)responseBody
{
    NSDictionary *responseDict = (NSDictionary *)responseBody;
    NSArray *responseMessages = responseDict[@"messages"][@"resource"];

    if (responseMessages && responseMessages.count > 0) {
        NSMutableArray *messages = [NSMutableArray array];

        for (NSDictionary *messageDict in responseMessages) {
            [messages addObject:[[NCMessage alloc] initWithDictionary:messageDict]];
        }

        self.messages = messages;
    }
}

#pragma mark - Forward invocation

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
