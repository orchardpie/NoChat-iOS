#import "NCWebService.h"
#import "NSURLSession+Spec.h"
#import "NSURLSessionDataTask+Spec.h"
#import "SingleTrack/SpecHelpers.h"

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
        __block NSURLSessionDataTask *task;

        subjectAction(^{
            [webService GET:@"/" parameters:@{} success:nil serverFailure:nil networkFailure:nil];
            task = webService.tasks.firstObject;
        });

        afterEach(^{
            [task removeObserver:webService forKeyPath:@"state"];
        });

        it(@"should send an HTTP GET request to the specified path", ^{
            task.originalRequest.HTTPMethod should equal(@"GET");
        });

        it(@"should include the auth token in the X-User-Token header", PENDING);
        
        it(@"should set the Accept header to application/json", PENDING);
    });

    context(@"with an active request", ^{
        __block NSURLAuthenticationChallenge<CedarDouble> *challenge;
        __block NSURLSessionDataTask *task;
        __block BOOL called;

        beforeEach(^{
            challenge = nice_fake_for([NSURLAuthenticationChallenge class]);
            called = NO;
            task = [webService GET:@"/" parameters:@{} success:^(id responseBody) {
                called = YES;
            } serverFailure:nil networkFailure:nil];
        });

        afterEach(^{
            [webService.tasks enumerateObjectsUsingBlock:^(id task, NSUInteger idx, BOOL *stop) {
                [task removeObserver:webService forKeyPath:@"state"];
            }];
        });

        describe(@"which receives an authentication challenge", ^{
            __block NSURLAuthenticationChallengeResponse *challengeResponse;

            subjectAction(^{
                [task receiveAuthenticationChallenge:challenge];
                challengeResponse = task.authenticationChallengeResponses.lastObject;
            });

            it(@"should return a default handling disposition", ^{
                challengeResponse.disposition should equal(NSURLSessionAuthChallengePerformDefaultHandling);
            });

            it(@"should not provide a credential (the challenge should use the default credential in the credential store)", ^{
                challengeResponse.credential should be_nil;
            });
        });

        describe(@"which receives a second authentication challenge", ^{
            __block NSURLCredential *proposedCredential;
            __block NSURLAuthenticationChallengeResponse *challengeResponse;

            subjectAction(^{
                [task receiveAuthenticationChallenge:challenge];
                challengeResponse = task.authenticationChallengeResponses.lastObject;
            });

            beforeEach(^{
                credentialStorage stub_method("removeCredential:forProtectionSpace:");
                NSInteger previousFailureCount = 1;
                proposedCredential = nice_fake_for([NSURLCredential class]);

                challenge stub_method("previousFailureCount").and_return(previousFailureCount);
                challenge stub_method("proposedCredential").and_return(proposedCredential);
            });

            it(@"should clear the credentials", ^{
                credentialStorage should have_received("removeCredential:forProtectionSpace:").with(proposedCredential, Arguments::any([NSURLProtectionSpace class]));
            });

            it(@"should return a reject protection space disposition", ^{
                challengeResponse.disposition should equal(NSURLSessionAuthChallengeRejectProtectionSpace);
            });

            it(@"should not provide credentials", ^{
                challengeResponse.credential should be_nil;
            });
        });

        describe(@"which completes with a 200 response", ^{
            __block NSURLResponse *response;
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"key": @"value" } options:0 error:nil];

            subjectAction(^{ [task completeWithResponse:response data:data error:nil]; });

            beforeEach(^{
                NSURL *url = [NSURL URLWithString:@"/"];
                response = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:@"1.0" headerFields:@{ @"Content-Type": @"application/json" }];
            });

            it(@"should invoke the success callback block", ^{
                called should be_truthy();
            });
        });
    });
});

SPEC_END
