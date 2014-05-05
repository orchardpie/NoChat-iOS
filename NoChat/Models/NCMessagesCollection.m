#import "NCMessagesCollection.h"
#import "NoChat.h"
#import "NCMessage.h"
#import "NCErrors.h"

@interface NCMessagesCollection () <NSCoding>

@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSArray *messages;

@end

@implementation NCMessagesCollection

- (instancetype)initWithMessagesDict:(NSDictionary *)messagesDict
{
    NCParameterAssert(messagesDict[@"location"]);

    if (self = [super init]) {
        self.location = messagesDict[@"location"];
        self.messages = [self parseMessagesFromMessageData:messagesDict[@"data"]];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.location = [decoder decodeObjectForKey:@"location"];
        self.messages = [decoder decodeObjectForKey:@"messages"];
    }

    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd]; return nil;
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
        NSDictionary *messagesDict = (NSDictionary *)responseBody;
        self.messages = [self parseMessagesFromMessageData:messagesDict[@"data"]];
        if (success) { success(); }

    } invalid:nil error:failure];
}

- (void)createMessageWithParameters:(NSDictionary *)parameters
                            success:(void(^)(NCMessage *))success
                            failure:(void(^)(NSError *))failure
{
    [noChat.webService POST:self.location parameters:parameters completion:^(id responseBody) {
        NCMessage *message = [[NCMessage alloc] initWithDictionary:(NSDictionary *)responseBody];
        if (success) { success(message); }
    } invalid:^(id responseBody) {
        if (failure) {
            failure([[NCErrors alloc] initWithJSONObject:responseBody].error);
        }
    } error:^(NSError *error) {
        if (failure) { failure(error); }
    }];
}

- (NSArray *)parseMessagesFromMessageData:(NSArray *)messageData
{
    if (messageData && messageData.count > 0) {
        NSMutableArray *messages = [NSMutableArray array];

        for (NSDictionary *messageDict in messageData) {
            if ([messageDict[@"disposition"] isEqualToString:@"received"]) {
                [messages addObject:[[NCMessage alloc] initWithDictionary:messageDict]];
            }
        }

        return messages;
    }

    return @[];
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
