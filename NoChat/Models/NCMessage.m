#import "NCMessage.h"
#import "NoChat.h"
#import "NCAnalytics.h"

@interface NCMessage () <NSCoding>

@end

@implementation NCMessage

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.messageId = dictionary[@"id"];
        self.createdAt = dictionary[@"created_at"];
        self.timeSavedDescription = dictionary[@"time_saved_description"];
        self.disposition = dictionary[@"disposition"];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.messageId = [decoder decodeObjectForKey:@"messageId"];
    self.createdAt = [decoder decodeObjectForKey:@"createdAt"];
    self.timeSavedDescription = [decoder decodeObjectForKey:@"timeSavedDescription"];
    self.body = [decoder decodeObjectForKey:@"body"];
    self.receiverEmail = [decoder decodeObjectForKey:@"receiverEmail"];
    self.disposition = [decoder decodeObjectForKey:@"disposition"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.messageId forKey:@"messageId"];
    [encoder encodeObject:self.createdAt forKey:@"createdAt"];
    [encoder encodeObject:self.timeSavedDescription forKey:@"timeSavedDescription"];
    [encoder encodeObject:self.body forKey:@"body"];
    [encoder encodeObject:self.receiverEmail forKey:@"receiverEmail"];
    [encoder encodeObject:self.disposition forKey:@"disposition"];
}

@end
