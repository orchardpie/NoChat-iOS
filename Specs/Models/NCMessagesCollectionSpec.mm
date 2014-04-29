#import "NCMessagesCollection.h"
#import "NCMessage.h"
#import "NoChat.h"
#import "NCWebService.h"
#import "NSURLSession+Spec.h"
#import "NSURLSessionDataTask+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCMessagesCollectionSpec)

describe(@"NCMessagesCollection", ^{
    __block NCMessagesCollection *messages;

    describe(@"-initWithMessagesDict:", ^{
        __block NSMutableDictionary *messagesDict;

        beforeEach(^{
            messagesDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"/messages", @"location", @[], @"data", nil];
        });

        subjectAction(^{ messages = [[NCMessagesCollection alloc] initWithMessagesDict:messagesDict]; });

        context(@"with a nil location", ^{
            beforeEach(^{
                messagesDict[@"location"] = nil;
            });

            itShouldRaiseException();
        });
    });

    describe(@"-fetchWithSuccess:success:failure:", ^{
        __block void (^success)();
        __block void (^failure)(NSError *error);
        __block bool successWasCalled;
        __block NSString *failureMessage;

        __block NSHTTPURLResponse *response;
        __block NSData *responseData;
        __block NSURLSessionDataTask *task;
        __block NSMutableDictionary *messagesDict;

        subjectAction(^{
            [messages fetchWithSuccess:success failure:failure];
            task = noChat.webService.tasks.firstObject;
            [task completeWithResponse:response data:responseData error:nil];
        });

        beforeEach(^{
            successWasCalled = NO;
            failureMessage = nil;

            success = [^() { successWasCalled = YES; } copy];
            failure = [^(NSError *error) { failureMessage = [error localizedDescription]; } copy];

            messagesDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"/messages", @"location", @[], @"data", nil];
            messages = [[NCMessagesCollection alloc] initWithMessagesDict:messagesDict];
        });

        it(@"should request the resource at its location", ^{
            task.originalRequest.URL.relativePath should equal(@"/messages");
        });

        context(@"when the fetch is successful", ^{
            beforeEach(^{
                response = makeResponse(200);
                responseData = [NSJSONSerialization dataWithJSONObject:validJSONFromResponseFixtureWithFileName(@"get_fetch_messages_response_200.json") options:0 error:nil];
            });

            it(@"should call the success block", ^{
                successWasCalled should be_truthy;
            });

            it(@"should not call the failure block", ^{
                failureMessage should be_empty;
            });

            it(@"should update the collection with only received messages", ^{
                messages.count should equal(2);
            });
        });

        context(@"when the fetch is unsuccessful", ^{
            beforeEach(^{
                response = makeResponse(500);
                responseData = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
            });

            it(@"should not call the success block", ^{
                successWasCalled should_not be_truthy;
            });

            it(@"should call the failure block", ^{
                failureMessage should_not be_empty;
            });

            it(@"should not update the collection", ^{
                messages.count should equal(0);
            });
        });
    });

    describe(@"-count", ^{
        context(@"when the collection has been initialized with messages", ^{
            beforeEach(^{
                NSDictionary *messagesDict = validJSONFromResponseFixtureWithFileName(@"get_fetch_messages_response_200.json");
                messages = [[NCMessagesCollection alloc] initWithMessagesDict:messagesDict];
            });

            it(@"should return the number of messages", ^{
                [messages count] should equal(2);
            });
        });

        context(@"when the collection has not been initialized with messages", ^{
            beforeEach(^{
                NSDictionary *messagesDict = @{ @"location": @"/messages",
                                                @"data": @[] };
                messages = [[NCMessagesCollection alloc] initWithMessagesDict:messagesDict];
            });

            it(@"should return zero", ^{
                [messages count] should equal(0);
            });
        });
    });
});

SPEC_END
