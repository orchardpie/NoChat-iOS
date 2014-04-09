#import "NCWebService.h"

typedef NSURLSessionAuthChallengeDisposition (^AFURLSessionTaskDidReceiveAuthenticationChallengeBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential);
@interface AFURLSessionManager (Spec)
- (AFURLSessionTaskDidReceiveAuthenticationChallengeBlock)taskDidReceiveAuthenticationChallenge;
@end


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

        it(@"should set the accept headers for the session", ^{
            webService.session.configuration.HTTPAdditionalHeaders[@"Accept"] should equal(@"application/json");
        });
    });

    describe(@"-saveCredentialWithEmail:password:", ^{
        NSString *email = @"kwo@example.com", *password = @"whoa";
        __block __unsafe_unretained NSURLCredential *credential;

        subjectAction(^{
            [webService saveCredentialWithEmail:email password:password];
        });

        beforeEach(^{
            credentialStorage stub_method("setDefaultCredential:forProtectionSpace:").and_do(^(NSInvocation *invocation) {
                [invocation getArgument:&credential atIndex:2];
            });
        });

        it(@"should store the credential in the system credential cache", ^{
            credentialStorage should have_received("setDefaultCredential:forProtectionSpace:");
            credential.user should equal(email);
            credential.password should equal(password);
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
        __block AFURLSessionTaskDidReceiveAuthenticationChallengeBlock challengeBlock;
        __block NSURLAuthenticationChallenge<CedarDouble> *challenge;
        __block NSURLCredential *credential;
        __block NSURLSessionAuthChallengeDisposition disposition;

        beforeEach(^{
            challenge = nice_fake_for([NSURLAuthenticationChallenge class]);
            credential = [[NSURLCredential alloc] initWithUser:@"foo" password:@"bar" persistence:NSURLCredentialPersistenceNone];

            [webService GET:@"/" parameters:@{} success:nil serverFailure:nil networkFailure:nil];
            challengeBlock = [webService taskDidReceiveAuthenticationChallenge];
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
            __block NSURLCredential<CedarDouble> *proposedCredential;

            beforeEach(^{
                credentialStorage stub_method("removeCredential:forProtectionSpace:");
                proposedCredential = nice_fake_for([NSURLCredential class]);

                NSInteger previousFailureCount = 1;
                challenge stub_method("previousFailureCount").and_return(previousFailureCount);
                challenge stub_method("proposedCredential").and_return(proposedCredential);
                challengeBlock(nil, nil, challenge, &credential);
            });

            describe(@"another authentication challenge", ^{
                subjectAction(^{
                    disposition = challengeBlock(nil, nil, challenge, &credential);
                });

                it(@"should clear the credentials", ^{
                    credentialStorage should have_received("removeCredential:forProtectionSpace:").with(proposedCredential, Arguments::any([NSURLProtectionSpace class]));
                });

                it(@"should return a challenge reject disposition", ^{
                    disposition should equal(NSURLSessionAuthChallengeRejectProtectionSpace);
                });
            });
        });
    });
});

SPEC_END
