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
        __block UserFetchCompletion completion;

        subjectAction(^{ [user fetch:completion]; });

        context(@"with a completion block", ^{
            __block bool wasCalled = NO;
            beforeEach(^{
                wasCalled = NO;
                completion = [^(NCCurrentUser *user, NSError *error) { wasCalled = YES; } copy];
                spy_on(noChat.webService);
            });

            context(@"when the fetch is successful", ^{
                typedef void(^AFSuccessBlock)(NSURLSessionDataTask *task, id responseObject);
                __block __unsafe_unretained AFSuccessBlock successBlock;

                beforeEach(^{
                        noChat.webService stub_method("GET:parameters:success:failure:").and_do(^(NSInvocation*invocation){
                        [invocation getArgument:&successBlock atIndex:4];
                        successBlock(nil, validJSONFromFetchUserResponse());
                    });
                });

                it(@"should parse the JSON dictionaries into NCMessage objects", ^{
                    user.messages.count should equal(2);
                });

                it(@"should call the success completion block", ^{
                    wasCalled should be_truthy;
                });
            });

            context(@"when the fetch is not successful", ^{
                it(@"should call the completion block with an error", PENDING);
            });

        });

        context(@"without a completion block", ^{
            beforeEach(^{
                completion = nil;
            });

            it(@"should not blow up", ^{
                // If we get here, it didn't blow up.
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

