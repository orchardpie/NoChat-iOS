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
    __block NCCurrentUser *user = nil;

    beforeEach(^{
        user = [[NCCurrentUser alloc] init];
    });

    describe(@"-fetch:", ^{
        __block UserFetchSuccess success;
        __block WebServiceServerFailure serverFailure;
        __block WebServiceNetworkFailure networkFailure;
        __block bool successWasCalled = NO;
        __block bool serverFailureWasCalled = NO;
        __block bool networkFailureWasCalled = NO;

        subjectAction(^{ [user fetch:success serverFailure:serverFailure networkFailure:networkFailure]; });

        beforeEach(^{
            successWasCalled = NO;
            serverFailureWasCalled = NO;
            serverFailureWasCalled = NO;

            success = [^(NCCurrentUser *currentUser) { successWasCalled = YES; } copy];
            serverFailure = [^(NSError *error) { serverFailureWasCalled = YES; } copy];
            networkFailure = [^(NSError *error) { networkFailureWasCalled = YES; } copy];

            spy_on(noChat.webService);
        });

        context(@"when the fetch is successful", ^{
            __block __unsafe_unretained WebServiceSuccess requestBlock;

            beforeEach(^{
                    noChat.webService stub_method("GET:parameters:success:serverFailure:networkFailure:").and_do(^(NSInvocation*invocation){
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
            __block __unsafe_unretained WebServiceServerFailure requestBlock;

            beforeEach(^{
                noChat.webService stub_method("GET:parameters:success:serverFailure:networkFailure:").and_do(^(NSInvocation*invocation){
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
            __block __unsafe_unretained WebServiceNetworkFailure requestBlock;

            beforeEach(^{
                noChat.webService stub_method("GET:parameters:success:serverFailure:networkFailure:").and_do(^(NSInvocation*invocation){
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

    describe(@"-saveCredentialsWithEmail:andPassword:", ^{
        __block __unsafe_unretained NSURLCredential *credential;

        subjectAction(^{ [user saveCredentialsWithEmail:@"kevinwo@orchardpie.com" andPassword:@"whoa"]; });

        beforeEach(^{
            spy_on(noChat.webService);
            noChat.webService stub_method("setCredential:").and_do(^(NSInvocation *invocation) {
                [invocation getArgument:&credential atIndex:2];
            });
        });

        it(@"should save the credentials and set them as the default", ^{
            credential.user should equal(@"kevinwo@orchardpie.com");
            credential.password should equal(@"whoa");
            credential.persistence should equal(NSURLCredentialPersistencePermanent);
        });
    });
});

SPEC_END

