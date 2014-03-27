#import "NCWebService.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCWebServiceSpec)

describe(@"NCWebService", ^{
    __block NCWebService *webService;
    __block NSURLCredentialStorage *credentialStorage;

    beforeEach(^{
        webService = [[NCWebService alloc] init];
        credentialStorage = [NSURLCredentialStorage sharedCredentialStorage];
        spy_on(credentialStorage);
    });

    describe(@"-init", ^{
        beforeEach(^{
            credentialStorage stub_method("defaultCredentialForProtectionSpace:");
        });
        it(@"should set the base URL", ^{
            webService.baseURL.absoluteString should_not be_nil;
        });

        it(@"should set the credential to nil", ^{
            webService.hasCredential should_not be_truthy;
        });
    });

    describe(@"-setCredential:", ^{
        __block NSURLCredential *credential;

        subjectAction(^{
            [webService setCredential:credential];
        });

        beforeEach(^{
            credentialStorage stub_method("setDefaultCredential:forProtectionSpace:");
            credential = [[NSURLCredential alloc] initWithUser:@"foo@example.com"
                                                      password:@"password"
                                                   persistence:NSURLCredentialPersistenceNone];
        });

        it(@"should store the credential in the system credential cache", ^{
            credentialStorage should have_received("setDefaultCredential:forProtectionSpace:");
        });
    });

    describe(@"-hasCredential", ^{
        __block NSURLCredential *credential;

        subjectAction(^{ credentialStorage stub_method("defaultCredentialForProtectionSpace:").and_return(credential); });

        context(@"but has a cached credential", ^{
            beforeEach(^{
                credential = [[NSURLCredential alloc] initWithUser:@"foo" password:@"bar" persistence:NSURLCredentialPersistenceNone];
            });

            it(@"should return YES", ^{
                [webService hasCredential] should be_truthy;
            });
        });

        context(@"without a cached credential", ^{
            beforeEach(^{
                credential = nil;
            });

            it(@"should return NO", ^{
                [webService hasCredential] should_not be_truthy;
            });
        });
    });

    describe(@"GET:parameters:success:failure:", ^{
        it(@"should send an HTTP GET request to the specified path", PENDING);
        it(@"should include the auth token in the X-NoChat-AuthToken header", PENDING);
        it(@"should set the Accept header to application/json", PENDING);

        context(@"on 200 response", ^{
            it(@"should invoke the success block", PENDING);
        });

        context(@"on 401 response", ^{
            it(@"should send a response to the authentication challenge", PENDING);

            context(@"on subsequent 401", ^{
                it(@"should clear the cached credentials", PENDING);
                it(@"should notify some sort of global mechanism that the user is no longer authenticated", PENDING);
            });

            context(@"on subsequent success", ^{
                it(@"should invoke the success block", PENDING);
            });

            context(@"on subsequent non-401 failure", ^{
                it(@"should invoke the failure block", PENDING);
            });
        });

        context(@"on response with another HTTP status code", ^{
            it(@"should invoke the failure block with something something server error", PENDING);
        });

        context(@"on network error", ^{
            it(@"should invoke the failure block with something something network error", PENDING);
        });
    });
});

SPEC_END
