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
    });

    context(@"with an active request", ^{
        typedef NSURLSessionAuthChallengeDisposition (^AFURLSessionTaskDidReceiveAuthenticationChallengeBlock)(NSURLSession *session, NSURLSessionTask *task, id<CedarDouble> challenge, NSURLCredential *__autoreleasing *credential);
        __block AFURLSessionTaskDidReceiveAuthenticationChallengeBlock challengeBlock;
        __block id<CedarDouble> challenge;
        __block NSURLCredential *credential;
        __block NSURLSessionAuthChallengeDisposition disposition;

        beforeEach(^{
            challenge = nice_fake_for([NSURLAuthenticationChallenge class]);
            credential = [[NSURLCredential alloc] initWithUser:@"foo" password:@"bar" persistence:NSURLCredentialPersistenceNone];

            [webService GET:@"/" parameters:@{} success:nil serverFailure:nil networkFailure:nil];
            challengeBlock = (AFURLSessionTaskDidReceiveAuthenticationChallengeBlock)[webService performSelector:NSSelectorFromString(@"taskDidReceiveAuthenticationChallenge")];
        });

        describe(@"which receives an authentication challenge", ^{
            subjectAction(^{
                disposition = challengeBlock(nil, nil, challenge, &credential);
            });

            it(@"should return a default handling disposition", ^{
                disposition should equal(NSURLSessionAuthChallengePerformDefaultHandling);
            });
        });

        context(@"which has already responded to an authentication challenge", ^{
            beforeEach(^{
                credentialStorage stub_method("removeCredential:forProtectionSpace:");

                NSInteger previousFailureCount = 1;
                challenge stub_method("previousFailureCount").and_return(previousFailureCount);
                challengeBlock(nil, nil, challenge, &credential);
            });

            describe(@"another authentication challenge", ^{
                subjectAction(^{
                    disposition = challengeBlock(nil, nil, challenge, &credential);
                });

                it(@"should clear the credentials", ^{
                    credentialStorage should have_received("removeCredential:forProtectionSpace:").with(credential, Arguments::any([NSURLProtectionSpace class]));
                });

                it(@"should return a challenge reject disposition", ^{
                    disposition should equal(NSURLSessionAuthChallengeRejectProtectionSpace);
                });
            });
        });
    });
});

SPEC_END
