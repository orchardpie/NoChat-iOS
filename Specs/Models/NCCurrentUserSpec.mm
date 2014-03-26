#import "NCCurrentUser.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

NSDictionary *dictFromLegitJSON() {
    NSString *userFixturePath = [NSString stringWithFormat:@"%@/%@", FIXTURES_DIR, @"post_login_response_200.json"];

//    NSString *userFixturePath = [[NSBundle mainBundle] pathForResource:@"post_login_response_200" ofType:@"json"];
    NSData *userData = [NSData dataWithContentsOfFile:userFixturePath];
    NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:userData options:0 error:nil];
    return userDict;
}

SPEC_BEGIN(NCCurrentUserSpec)

describe(@"NCCurrentUser", ^{
    __block NCCurrentUser *user = nil;
    __block NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:@"localhost"
                                                                                          port:3000
                                                                                      protocol:@"http"
                                                                                         realm:nil
                                                                          authenticationMethod:NSURLAuthenticationMethodHTTPBasic];
    NSString *name = @"Sally User";

    __block id<CedarDouble> credential = nice_fake_for([NSURLCredential class]);

    beforeEach(^{
        user = [[NCCurrentUser alloc] initWithDictionary:@{ @"name": name }];
    });

    describe(@"+logInWithEmail:andPassword:completion:", ^{
        __block NSError *blockError = nil;
        __block UserLoginCompletion completion = nil;

        subjectAction(^{
            [NCCurrentUser logInWithEmail:@"partyman" andPassword:@"partytime" completion:completion];
        });

        context(@"with a completion block", ^{
            beforeEach(^{
                completion = [^(NCCurrentUser *user, NSError *error) { blockError = error; } copy];
            });

            it(@"should initialize a user and an error with the completion block", ^{
                blockError should_not be_nil;
            });
        });

        context(@"without a completion block", ^{
            beforeEach(^{
                completion = nil;
            });

            it(@"should not explode", ^{
                // If we're here, it didn't blow up.
            });
        });
    });

    describe(@"-initWithDictionary:", ^{
        context(@"with a legit dictionary", ^{
            it(@"should set name from the name key", ^{
                user.name should equal(name);
            });
        });

        context(@"with no dictionary", ^{
            it(@"should throw an error", ^{
                ^{ [[NCCurrentUser alloc] initWithDictionary:nil]; } should raise_exception;
            });
        });
    });

    describe(@"-saveCredentialsWithEmail:andPassword", ^{
        __block NSURLCredentialStorage *credentialStorage;
        __block __unsafe_unretained NSURLCredential *credential;

        subjectAction(^{ [user saveCredentialsWithEmail:@"kevinwo@orchardpie.com" andPassword:@"whoa"]; });

        beforeEach(^{
            credentialStorage = [NSURLCredentialStorage sharedCredentialStorage];
            spy_on(credentialStorage);
            credentialStorage stub_method("setDefaultCredential:forProtectionSpace:").and_do(^(NSInvocation *invocation) {
                [invocation getArgument:&credential atIndex:2];
            });
        });

        it(@"should save the credentials and set them as the default", ^{
            credentialStorage should have_received("setDefaultCredential:forProtectionSpace:");
            credential.user should equal(@"kevinwo@orchardpie.com");
            credential.password should equal(@"whoa");
            credential.persistence should equal(NSURLCredentialPersistencePermanent);
        });
    });
});

SPEC_END

