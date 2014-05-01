#import "NCWebService.h"
#import "NoChat.h"
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

    describe(@"GET:parameters:completion:invalid:error:", ^{
        __block NSURLSessionDataTask *task;

        subjectAction(^{
            [webService GET:@"/" parameters:@{} completion:nil invalid:nil error:nil];
            task = webService.tasks.firstObject;
        });

        afterEach(^{
            [task removeObserver:webService forKeyPath:@"state"];
        });

        it(@"should send an HTTP GET request to the specified path", ^{
            task.originalRequest.HTTPMethod should equal(@"GET");
        });
    });

    describe(@"POST:parameters:completion:invalid:error:", ^{
        __block NSURLSessionDataTask *task;

        subjectAction(^{
            [webService POST:@"/messages/" parameters:@{} completion:nil invalid:nil error:nil];
            task = webService.tasks.firstObject;
        });

        afterEach(^{

            [task removeObserver:webService forKeyPath:@"state"];
        });

        it(@"should send an HTTP POST request to the specified path", ^{
            task.originalRequest.HTTPMethod should equal(@"POST");
        });
    });

    sharedExamplesFor(@"valid responses to a request", ^(NSDictionary *sharedContext) {
        __block NSURLAuthenticationChallenge<CedarDouble> *challenge;
        __block NSURLSessionDataTask *task;
        __block BOOL completionCalled;
        __block BOOL invalidCalled;
        __block BOOL errorCalled;

        beforeEach(^{
            challenge = nice_fake_for([NSURLAuthenticationChallenge class]);
            completionCalled = NO;
            invalidCalled = NO;
            errorCalled = NO;
            NSURLSessionDataTask *(^createTaskAction)(id, id, id) = sharedContext[@"createTaskAction"];
            task = createTaskAction(^(id responseBody) {
                completionCalled = YES;
            }, ^(NSString *failureMessage) {
                invalidCalled = YES;
            }, ^(NSError *) {
                errorCalled = YES;
            });
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

        sharedExamplesFor(@"a successful AFNetworking response", ^(NSDictionary *sharedContext) {
            __block NSMutableDictionary *headerFields;

            beforeEach(^{
                headerFields = sharedContext[@"headerFields"];
            });

            context(@"when the response contains a user authentication token", ^{
                beforeEach(^{
                    webService.requestSerializer.HTTPRequestHeaders[@"X-User-Token"] should be_nil;
                    headerFields[@"X-User-Token"] = @"wibble";
                });

                it(@"should set the user authentication token for the session", ^{
                    webService.requestSerializer.HTTPRequestHeaders[@"X-User-Token"] should equal(@"wibble");
                });
            });

            context(@"when the web service has previously saved an auth token", ^{
                beforeEach(^{
                    [webService.requestSerializer setValue:@"foobar" forHTTPHeaderField:@"X-User-Token"];
                });

                context(@"when the response does not contain an authentication token", ^{
                    beforeEach(^{
                        headerFields[@"X-User-Token"] should be_nil;
                    });

                    it(@"should not clear any previously saved auth token", ^{
                        webService.requestSerializer.HTTPRequestHeaders[@"X-User-Token"] should equal(@"foobar");
                    });
                });
            });
        });

        describe(@"which completes with a 200 response", ^{
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"key": @"value" } options:0 error:nil];
            NSURL *url = [NSURL URLWithString:@"/"];
            __block NSMutableDictionary *headerFields;

            subjectAction(^{
                [task completeWithResponse:[[NSHTTPURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:@"1.0" headerFields:headerFields]
                                      data:data
                                     error:nil];
            });

            beforeEach(^{
                headerFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type", nil];
                SpecHelper.specHelper.sharedExampleContext[@"headerFields"] = headerFields;
            });

            it(@"should invoke the completion callback block", ^{
                completionCalled should be_truthy;
            });

            it(@"should not invoke the invalid callback block", ^{
                invalidCalled should_not be_truthy;
            });

            it(@"should not invoke the error callback block", ^{
                errorCalled should_not be_truthy;
            });

            itShouldBehaveLike(@"a successful AFNetworking response");
        });

        describe(@"which completes with a 401 response", ^{
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
            NSURL *url = [NSURL URLWithString:@"/"];
            __block NSMutableDictionary *headerFields;

            subjectAction(^{
                [task completeWithResponse:[[NSHTTPURLResponse alloc] initWithURL:url statusCode:401 HTTPVersion:@"1.0" headerFields:headerFields]
                                      data:data
                                     error:nil];
            });

            beforeEach(^{
                headerFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type", nil];
                SpecHelper.specHelper.sharedExampleContext[@"headerFields"] = headerFields;
            });

            it(@"should not invoke the completion callback block", ^{
                completionCalled should_not be_truthy;
            });

            it(@"should not invoke the invalid callback block", ^{
                invalidCalled should_not be_truthy;
            });

            it(@"should not invoke the error callback block", ^{
                errorCalled should_not be_truthy;
            });

            it(@"should notify the NoChat global that the user failed authentication", ^{
                noChat should have_received("userDidFailAuthentication");
            });

            itShouldBehaveLike(@"a successful AFNetworking response");
        });

        describe(@"which completes with a 422 response", ^{
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"message": @"Error!" } options:0 error:nil];
            NSURL *url = [NSURL URLWithString:@"/"];
            __block NSMutableDictionary *headerFields;

            subjectAction(^{
                [task completeWithResponse:[[NSHTTPURLResponse alloc] initWithURL:url statusCode:422 HTTPVersion:@"1.0" headerFields:headerFields]
                                      data:data
                                     error:nil];
            });

            beforeEach(^{
                headerFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type", nil];
                SpecHelper.specHelper.sharedExampleContext[@"headerFields"] = headerFields;
            });

            it(@"should invoke the invalid callback block", ^{
                invalidCalled should be_truthy;
            });


            it(@"should not invoke the error callback block", ^{
                errorCalled should_not be_truthy;
            });

            it(@"should not invoke the completion callback block", ^{
                completionCalled should_not be_truthy;
            });

            itShouldBehaveLike(@"a successful AFNetworking response");
        });

        describe(@"which completes with a 500 response", ^{
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"Does not": @"matter" } options:0 error:nil];
            NSURL *url = [NSURL URLWithString:@"/"];
            __block NSMutableDictionary *headerFields;

            subjectAction(^{
                [task completeWithResponse:[[NSHTTPURLResponse alloc] initWithURL:url statusCode:500 HTTPVersion:@"1.0" headerFields:headerFields]
                                      data:data
                                     error:nil];
            });

            beforeEach(^{
                headerFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type", nil];
                SpecHelper.specHelper.sharedExampleContext[@"headerFields"] = headerFields;
            });

            it(@"should invoke the error callback block", ^{
                errorCalled should be_truthy;
            });

            it(@"should not invoke the invalid callback block", ^{
                invalidCalled should_not be_truthy;
            });

            it(@"should not invoke the completion callback block", ^{
                completionCalled should_not be_truthy;
            });

            itShouldBehaveLike(@"a successful AFNetworking response");
        });
    });

    context(@"with an active GET request", ^{
        beforeEach(^{
            SpecHelper.specHelper.sharedExampleContext[@"createTaskAction"] = [^NSURLSessionDataTask *(id completion, id invalid, id error) {
                return [webService GET:@"/" parameters:@{} completion:completion invalid:invalid error:error];
            } copy];
        });

        itShouldBehaveLike(@"valid responses to a request");
    });

    context(@"with an active POST request", ^{
        beforeEach(^{
            SpecHelper.specHelper.sharedExampleContext[@"createTaskAction"] = [^NSURLSessionDataTask *(id completion, id invalid, id error) {
                return [webService POST:@"/" parameters:@{} completion:completion invalid:invalid error:error];
            } copy];
        });

        itShouldBehaveLike(@"valid responses to a request");
    });
});

SPEC_END
