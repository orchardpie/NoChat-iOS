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
        __block UserFetchSuccessBlock successBlock;
        __block UserFetchFailureBlock failureBlock;
        __block bool successWasCalled = NO;
        __block bool failureWasCalled = NO;

        subjectAction(^{ [user fetch:successBlock failure:failureBlock]; });

        beforeEach(^{
            successWasCalled = NO;
            failureWasCalled = NO;

            successBlock = [^(NCCurrentUser *currentUser) { successWasCalled = YES; } copy];
            failureBlock = [^(NSError *error) { failureWasCalled = YES; } copy];

            spy_on(noChat.webService);
        });

        context(@"when the fetch is successful", ^{
            typedef void(^AFSuccessBlock)(NSURLSessionDataTask *task, id responseObject);
            __block __unsafe_unretained AFSuccessBlock requestBlock;

            beforeEach(^{
                    noChat.webService stub_method("GET:parameters:success:failure:").and_do(^(NSInvocation*invocation){
                    [invocation getArgument:&requestBlock atIndex:4];
                    requestBlock(nil, validJSONFromFetchUserResponse());
                });
            });

            it(@"should parse the JSON dictionaries into NCMessage objects", ^{
                user.messages.count should equal(2);
            });

            it(@"should call the success completion block", ^{
                successWasCalled should be_truthy;
            });

            it(@"should not call the failure block", ^{
                failureWasCalled should_not be_truthy;
            });

        });

        context(@"when the fetch is not successful", ^{
            typedef void(^AFFailureBlock)(NSURLSessionDataTask *task, NSError *error);
            __block __unsafe_unretained AFFailureBlock requestBlock;

            beforeEach(^{
                noChat.webService stub_method("GET:parameters:success:failure:").and_do(^(NSInvocation*invocation){
                    [invocation getArgument:&requestBlock atIndex:5];
                    NSError *error = [[NSError alloc] init];
                    requestBlock(nil, error);
                });
            });

            it(@"should not call the success block", ^{
                successWasCalled should_not be_truthy;
            });
            it(@"should call the failure block with an error", ^{
                failureWasCalled should be_truthy;
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

