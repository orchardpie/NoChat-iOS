#import "NCMessage.h"
#import "NoChat.h"
#import "NCWebService.h"
#import "NSURLSession+Spec.h"
#import "NSURLSessionDataTask+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;



SPEC_BEGIN(NCMessageSpec)

describe(@"NCMessage", ^{
    __block NCMessage *message;
    __block NSDictionary *dictionary;

    beforeEach(^{
        dictionary = @{ @"id": @42,
                        @"created_at": @"4/14/14",
                        @"time_saved_description": @"666 seconds saved",
                        @"disposition": @"received"
                      };
    });

    describe(@"-init", ^{
        subjectAction(^{ message = [[NCMessage alloc] initWithDictionary:dictionary]; });

        it(@"should set the ID", ^{
            message.messageId should equal(42);
        });

        it(@"should set the created at date string", ^{
            message.createdAt should equal(@"4/14/14");
        });

        it(@"should set time saved in milliseconds", ^{
            message.timeSavedDescription should equal(@"666 seconds saved");
        });

        it(@"should set the disposition", ^{
            message.disposition should equal(@"received");
        });
    });

    describe(@"-saveWithSuccess:failure:", ^{
        __block void (^success)();
        __block WebServiceError failure;
        __block BOOL successWasCalled;
        __block NSString *failureMessage;

        __block NSHTTPURLResponse *response;
        __block NSData *responseData;

        subjectAction(^{
            [message saveWithSuccess:success failure:failure];
            NSURLSessionDataTask *task = noChat.webService.tasks.firstObject;
            [task completeWithResponse:response data:responseData error:nil];
        });

        beforeEach(^{
            message = [[NCMessage alloc] init];
            message.receiverEmail = @"whoanelly@orchardpie.com";
            message.body = @"I like turtles.";

            successWasCalled = NO;
            failureMessage = nil;

            success = [^() { successWasCalled = YES; } copy];
            failure = [^(NSError *error) { failureMessage = [error localizedDescription]; } copy];

        });

        context(@"when the save is successful", ^{
            beforeEach(^{
                response = makeResponse(201);
                responseData = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
            });

            it(@"should call the success completion block", ^{
                successWasCalled should be_truthy;
            });

            it(@"should not call the failure block", ^{
                failureMessage should be_nil;
            });
        });

        context(@"when the save yields a validation error", ^{
            beforeEach(^{
                response = makeResponse(422);
                responseData = [NSJSONSerialization dataWithJSONObject:@{@"errors": @{@"email": @[@"E-mail is invalid"] } } options:0 error:nil];
            });

            it(@"should not call the success block", ^{
                successWasCalled should_not be_truthy;
            });

            it(@"should call the failure block with an error", ^{
                failureMessage should equal(@"E-mail is invalid");
            });

            it(@"should notify GA", ^{
                noChat.analytics should have_received("sendAction:withCategory:andError:").with(@"Error Sending Message", @"Messages", Arguments::any([NSError class]));
            });
        });

        context(@"when the fetch attempt yields a non-validation failure", ^{
            beforeEach(^{
                response = makeResponse(500);
                responseData = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
            });

            it(@"should not call the success block", ^{
                successWasCalled should_not be_truthy;
            });


            it(@"should call the failure block with an error", ^{
                failureMessage should_not be_nil;
            });

            it(@"should not notify GA", ^{
                noChat.analytics should_not have_received("sendAction:withCategory:andError:");
            });
        });
    });
});

SPEC_END
