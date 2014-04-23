#import "NCMessagesCollection.h"
#import "NCMessage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCMessagesCollectionSpec)

describe(@"NCMessagesCollection", ^{
    __block NCMessagesCollection *messages;

    describe(@"-initWithLocation:messages", ^{
        __block NSString *location;
        __block NSArray *messages;

        beforeEach(^{
            messages = @[];
        });

        subjectAction(^{ [[NCMessagesCollection alloc] initWithLocation:location messages:messages]; });

        context(@"with a nil location", ^{
            beforeEach(^{
                location = nil;
            });

            itShouldRaiseException();
        });
    });

    describe(@"-fetchWithSuccess:success:failure:", ^{
        __block void (

        subjectAction(^{ [messages fetchWithSuccess:<#^(void)success#> failure:<#^(NSError *error)failure#>]; });
    });

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
