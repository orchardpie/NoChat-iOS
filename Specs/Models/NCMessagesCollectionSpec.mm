#import "NCMessagesCollection.h"
#import "NCMessage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCMessagesCollectionSpec)

describe(@"NCMessagesCollection", ^{
    __block NCMessagesCollection *messages;

    describe(@"-count", ^{
        context(@"when the collection has been initialized with messages", ^{
            beforeEach(^{
                NCMessage *message1 = [[NCMessage alloc] init];
                NCMessage *message2 = [[NCMessage alloc] init];
                NSArray *messagesAry = @[message1, message2];
                messages = [[NCMessagesCollection alloc]initWithLocation:@"/messages" messages:messagesAry];
            });

            it(@"should return the number of messages", ^{
                [messages count] should equal(2);
            });
        });

        context(@"when the collection has not been initialized with messages", ^{
            beforeEach(^{
                messages = [[NCMessagesCollection alloc] initWithLocation:@"/messages" messages:@[]];
            });

            it(@"should return zero", ^{
                [messages count] should equal(0);
            });
        });
    });
});

SPEC_END
