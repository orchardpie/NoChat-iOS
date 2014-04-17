#import "NCCurrentUser.h"
#import "NoChat.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

id validJSONFromFetchUserResponse() {
    NSString *userFixturePath = [NSString stringWithFormat:@"%@/%@", FIXTURES_DIR, @"get_fetch_user_response_200.json"];
    NSData *userFixtureData = [NSData dataWithContentsOfFile:userFixturePath options:0 error:nil];
    return [NSJSONSerialization JSONObjectWithData:userFixtureData options:0 error:nil];
}


SPEC_BEGIN(NCCurrentUserSpec)

describe(@"NCCurrentUser", ^{
    __block NCCurrentUser *user;
    __block void (^success)();
    __block WebServiceInvalid serverFailure;
    __block WebServiceError networkFailure;
    __block bool successWasCalled;
    __block BOOL serverFailureWasCalled;
    __block BOOL networkFailureWasCalled;

    beforeEach(^{
        spy_on(noChat.webService);
        noChat.webService stub_method("saveCredentialWithEmail:password:");

        user = [[NCCurrentUser alloc] init];
    });

    describe(@"-fetchWithSuccess:serverFailure:networkFailure:", ^{
        subjectAction(^{ [user fetchWithSuccess:success serverFailure:serverFailure networkFailure:networkFailure]; });

        beforeEach(^{
            successWasCalled = NO;
            serverFailureWasCalled = NO;
            networkFailureWasCalled = NO;

            success = [^() { successWasCalled = YES; } copy];
            serverFailure = [^(NSError *error) { serverFailureWasCalled = YES; } copy];
            networkFailure = [^(NSError *error) { networkFailureWasCalled = YES; } copy];
        });

        context(@"when the fetch is successful", ^{
            __block __unsafe_unretained WebServiceCompletion requestBlock;

            beforeEach(^{
                    noChat.webService stub_method("GET:parameters:completion:invalid:error:").and_do(^(NSInvocation*invocation){
                    [invocation getArgument:&requestBlock atIndex:4];
                    requestBlock(validJSONFromFetchUserResponse());
                });
            });

            it(@"should parse the JSON dictionaries into NCMessage objects", ^{
                user.messages.count should equal(2);
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

        context(@"when the fetch attempt yields a server failure", ^{
            __block __unsafe_unretained WebServiceInvalid requestBlock;

            beforeEach(^{
                noChat.webService stub_method("GET:parameters:completion:invalid:error:").and_do(^(NSInvocation*invocation){
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

            it(@"should not change the user messages collection", ^{
                user.messages should be_empty;
            });
        });

        context(@"when the fetch attempt yields a network failure", ^{
            __block __unsafe_unretained WebServiceError requestBlock;

            beforeEach(^{
                noChat.webService stub_method("GET:parameters:completion:invalid:error:").and_do(^(NSInvocation*invocation){
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

            it(@"should not change the user messages collection", ^{
                user.messages should be_empty;
            });
        });
    });

    describe(@"-signUpWithEmail:password:completion:invalid:error:", ^{
        NSString *email = @"wibble@example.com", *password = @"password123";

        subjectAction(^{ [user signUpWithEmail:email password:password success:success serverFailure:serverFailure networkFailure:networkFailure]; });

        beforeEach(^{
            successWasCalled = NO;
            serverFailureWasCalled = NO;
            networkFailureWasCalled = NO;

            success = [^() { successWasCalled = YES; } copy];
            serverFailure = [^(NSError *error) { serverFailureWasCalled = YES; } copy];
            networkFailure = [^(NSError *error) { networkFailureWasCalled = YES; } copy];

            spy_on(noChat.webService);
        });

        it(@"should POST to /users", ^{
            noChat.webService should have_received("POST:parameters:completion:invalid:error:");
        });

        it(@"should send the email and password to the server", ^{
            [[(id<CedarDouble>)noChat.webService sent_messages] firstObject];
        });

        context(@"when the signup is successful", ^{
            __block __unsafe_unretained WebServiceCompletion successBlock;

            beforeEach(^{
                noChat.webService stub_method("POST:parameters:completion:invalid:error:").and_do(^(NSInvocation*invocation){
                    [invocation getArgument:&successBlock atIndex:4];
                    successBlock(validJSONFromFetchUserResponse());
                });
            });

            it(@"should set the credentials", ^{
                noChat.webService should have_received("saveCredentialWithEmail:password:").with(email, password);
            });

            it(@"should parse the JSON dictionaries into NCMessage objects", ^{
                user.messages.count should equal(2);
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

        context(@"when the signup attempt yields a server failure", ^{
            __block __unsafe_unretained WebServiceInvalid requestBlock;

            beforeEach(^{
                noChat.webService stub_method("POST:parameters:completion:invalid:error:").and_do(^(NSInvocation*invocation){
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

            it(@"should not change the user messages collection", ^{
                user.messages should be_empty;
            });
        });

        context(@"when the signup attempt yields a network failure", ^{
            __block __unsafe_unretained WebServiceError requestBlock;

            beforeEach(^{
                noChat.webService stub_method("POST:parameters:completion:invalid:error:").and_do(^(NSInvocation*invocation){
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

            it(@"should not change the user messages collection", ^{
                user.messages should be_empty;
            });
        });
    });

    describe(@"-saveCredentialWithEmail:password:", ^{
        NSString *email = @"kevinwo@orchardpie.com", *password = @"whoa";

        subjectAction(^{ [user saveCredentialWithEmail:email password:password]; });

        it(@"should save the credentials and set them as the default", ^{
            noChat.webService should have_received("saveCredentialWithEmail:password:").with(email, password);
        });
    });
});

SPEC_END

