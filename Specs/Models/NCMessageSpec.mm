#import "NCMessage.h"
#import "NoChat.h"
#import "NCWebService.h"

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
            message.time_saved should equal(500);
        });
    });

    describe(@"-save", ^{
        __block void (^success)();
        __block WebServiceServerFailure serverFailure;
        __block WebServiceNetworkFailure networkFailure;
        __block bool successWasCalled;
        __block BOOL serverFailureWasCalled;
        __block BOOL networkFailureWasCalled;

        subjectAction(^{ [message saveWithSuccess:success serverFailure:serverFailure networkFailure:networkFailure]; });

        beforeEach(^{
            spy_on(noChat.webService);

            message = [[NCMessage alloc] init];
            message.receiver_email = @"whoanelly@orchardpie.com";
            message.body = @"I like turtles.";

            successWasCalled = NO;
            serverFailureWasCalled = NO;
            networkFailureWasCalled = NO;

            success = [^() { successWasCalled = YES; } copy];
            serverFailure = [^(NSError *error) { serverFailureWasCalled = YES; } copy];
            networkFailure = [^(NSError *error) { networkFailureWasCalled = YES; } copy];
        });

        context(@"when the save is successful", ^{
            __block __unsafe_unretained WebServiceSuccess requestBlock;

            beforeEach(^{
                noChat.webService stub_method("POST:parameters:success:serverFailure:networkFailure:").and_do(^(NSInvocation*invocation){
                    [invocation getArgument:&requestBlock atIndex:4];
                    requestBlock(nil);
                });
            });

            it(@"should call the success completion block", ^{
                successWasCalled should be_truthy;
            });

            it(@"should not call the server failure block", ^{
                serverFailureWasCalled should_not be_truthy;
            });

            it(@"should not call the network failure block", ^{
                networkFailureWasCalled should_not be_truthy;
            });
        });

        context(@"when the save yield a server failure", ^{
            __block __unsafe_unretained WebServiceServerFailure requestBlock;

            beforeEach(^{
                noChat.webService stub_method("POST:parameters:success:serverFailure:networkFailure:").and_do(^(NSInvocation*invocation){
                    [invocation getArgument:&requestBlock atIndex:5];
                    NSString *failureMessage = @"failure message";
                    requestBlock(failureMessage);
                });
            });

            it(@"should not call the success block", ^{
                successWasCalled should_not be_truthy;
            });

            it(@"should call the server failure block with an error", ^{
                serverFailureWasCalled should be_truthy;
            });

            it(@"should not call the network failure block with an error", ^{
                networkFailureWasCalled should_not be_truthy;
            });
        });

        context(@"when the fetch attempt yields a network failure", ^{
            __block __unsafe_unretained WebServiceNetworkFailure requestBlock;

            beforeEach(^{
                noChat.webService stub_method("POST:parameters:success:serverFailure:networkFailure:").and_do(^(NSInvocation*invocation){
                    [invocation getArgument:&requestBlock atIndex:6];
                    NSError *error = [NSError errorWithDomain:@"TestErrorDomain" code:-1004 userInfo:@{ NSLocalizedDescriptionKey: @"Could not connect to server",
                                                                                                        NSLocalizedRecoverySuggestionErrorKey: @"Try harder" }];
                    requestBlock(error);
                });
            });

            it(@"should not call the success block", ^{
                successWasCalled should_not be_truthy;
            });

            it(@"should not call the server failure block with an error", ^{
                serverFailureWasCalled should_not be_truthy;
            });

            it(@"should call the network failure block with an error", ^{
                networkFailureWasCalled should be_truthy;
            });
        });
    });
});

SPEC_END
