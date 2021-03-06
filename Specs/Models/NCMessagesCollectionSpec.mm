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
    NSString *location = @"/messages";

    beforeEach(^{
        messages = [[NCMessagesCollection alloc] initWithMessagesDict:@{ @"location": location, @"data": @[] }];
    });

    describe(@"-initWithMessagesDict:", ^{
        __block NSDictionary *messagesDict;

        subjectAction(^{
            messages = [[NCMessagesCollection alloc] initWithMessagesDict:messagesDict];
        });

        context(@"with a nil location", ^{
            beforeEach(^{
                messagesDict = @{};
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

    describe(@"-createMessageWithParameters:success:failure:", ^{
        __block void (^success)(NCMessage *message);
        __block void (^failure)(NSError *error);
        __block NCMessage *aMessage;
        __block NSString *failureMessage;

        __block NSURLSessionDataTask *task;
        __block NSDictionary *parameters;
        __block NSHTTPURLResponse *response;
        __block NSData *responseData;
        __block NSError *error;

        subjectAction(^{
            [messages createMessageWithParameters:parameters success:success failure:failure];
            task = noChat.webService.tasks.lastObject;
            [task completeWithResponse:response data:responseData error:error];
        });

        beforeEach(^{
            parameters = @{ @"email": @"wibble@wibs.com",
                            @"body": @"Nice message" };

            aMessage = nil;
            success = [^(NCMessage *message) { aMessage = message; } copy];

            failureMessage = nil;
            failure = [^(NSError *error) { failureMessage = [error localizedDescription]; } copy];
        });

        it(@"should create a POST request to its location", ^{
            task.originalRequest.HTTPMethod should equal(@"POST");
            task.originalRequest.URL.path should equal(location);
        });

        it(@"should include the specified params in the POST request body", ^{
            NSString *body = [[NSString alloc] initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
            body should contain(@"email=wibble%40wibs.com");
            body should contain(@"body=Nice%20message");
        });

        context(@"when the message creation is successful", ^{
            beforeEach(^{
                response = makeResponse(201);
                responseData = [NSJSONSerialization dataWithJSONObject:validJSONFromResponseFixtureWithFileName(@"post_create_message_response_201.json") options:0 error:nil];
            });

            context(@"with a success block", ^{
                it(@"should call the success block", ^{
                    aMessage should_not be_nil;
                });
            });

            context(@"without a success block", ^{
                beforeEach(^{
                    success = nil;
                });

                it(@"should not explode", ^{
                    aMessage should be_nil;
                });
            });

            it(@"should not call the failure block", ^{
                failureMessage should be_empty;
            });
        });

        context(@"when the message creation fails", ^{
            beforeEach(^{
                response = makeResponse(422);
                responseData = [NSJSONSerialization dataWithJSONObject:validJSONFromResponseFixtureWithFileName(@"post_create_message_response_422.json") options:0 error:nil];
            });

            it(@"should not call the success block", ^{
                aMessage should be_nil;
            });

            context(@"with a failure block", ^{
                it(@"should call the failure block", ^{
                    failureMessage should equal(@"Please enter a valid email address");
                });
            });

            context(@"without a failure block", ^{
                beforeEach(^{
                    failure = nil;
                });

                it(@"should not explode", ^{
                    failureMessage should be_nil;
                });
            });
        });

        context(@"with a network error", ^{
            beforeEach(^{
                response = nil;
                responseData = nil;

                error = [NSError errorWithDomain:@"Test" code:123 userInfo:@{ NSLocalizedDescriptionKey: @"You blew it." }];
                failureMessage = nil;
            });

            context(@"with a failure block", ^{
                it(@"should call the failure block", ^{
                    failureMessage should equal(@"You blew it.");
                });
            });

            context(@"without a failure block", ^{
                beforeEach(^{
                    failure = nil;
                });

                it(@"should not explode", ^{
                    failureMessage should be_nil;
                });
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
