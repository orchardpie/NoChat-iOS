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
        dictionary = @{ @"time_saved": @500, @"disposition": @"sent"};
    });

    describe(@"-init", ^{
        subjectAction(^{ message = [[NCMessage alloc] initWithDictionary:dictionary]; });

        it(@"should set time saved in milliseconds", ^{
            message.timeSaved should equal(500);
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
                responseData = [NSJSONSerialization dataWithJSONObject:@{@"errors": @{@"email": @[@"is invalid"] } } options:0 error:nil];
            });

            it(@"should not call the success block", ^{
                successWasCalled should_not be_truthy;
            });

            it(@"should call the failure block with an error", ^{
                failureMessage should equal(@"email is invalid");
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
        });
    });
});

SPEC_END
