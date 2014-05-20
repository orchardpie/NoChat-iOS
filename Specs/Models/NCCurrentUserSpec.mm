#import "NCCurrentUser.h"
#import "NoChat.h"
#import "NCWebService.h"
#import "NCMessagesCollection.h"
#import "NCMessage.h"
#import "NSURLSession+Spec.h"
#import "NSURLSessionDataTask+Spec.h"
#import "NSUserDefaults+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCCurrentUserSpec)

describe(@"NCCurrentUser", ^{
    __block NCCurrentUser *user;
    __block void (^success)();
    __block void (^failure)(NSError *error);
    __block BOOL successWasCalled;
    __block NSString *failureMessage;

    __block NSHTTPURLResponse *response;
    __block NSData *responseData;

    beforeEach(^{
        spy_on(noChat.webService);
        noChat.webService stub_method("saveCredentialWithEmail:password:");

        user = [[NCCurrentUser alloc] init];
    });

    afterEach(^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"currentUser"];
        [userDefaults synchronize];
    });

    describe(@"archiving and unarchiving", ^{
        __block NCCurrentUser *protoUser;

        subjectAction(^{ user = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:protoUser]]; });

        beforeEach(^{
            protoUser = [[NCCurrentUser alloc] init];
            [protoUser fetchWithSuccess:nil failure:nil];

            NSURLSessionDataTask *task = noChat.webService.tasks.firstObject;
            NSHTTPURLResponse *response = makeResponse(200);
            NSData *responseData = dataFromResponseFixtureWithFileName(@"get_fetch_user_response_200.json");
            [task completeWithResponse:response data:responseData error:nil];
        });

        it(@"should set the messages collection", ^{
            user.messages.count should equal(protoUser.messages.count);
        });
    });

    describe(@"-fetchWithSuccess:success:failure:", ^{
        subjectAction(^{
            [user fetchWithSuccess:success failure:failure];
            NSURLSessionDataTask *task = noChat.webService.tasks.firstObject;
            [task completeWithResponse:response data:responseData error:nil];
        });

        beforeEach(^{
            successWasCalled = NO;
            failureMessage = nil;

            success = [^() { successWasCalled = YES; } copy];
            failure = [^(NSError *error) { failureMessage = [error localizedDescription]; } copy];
        });

        context(@"when the fetch is successful", ^{
            __block NSUserDefaults *userDefaults;

            beforeEach(^{
                response = makeResponse(201);
                responseData = [NSJSONSerialization dataWithJSONObject:validJSONFromResponseFixtureWithFileName(@"get_fetch_user_response_200.json") options:0 error:nil];
                userDefaults = [NSUserDefaults standardUserDefaults];
            });

            it(@"should parse the JSON dictionaries into NCMessage objects", ^{
                user.messages.count should equal(2);
            });

            it(@"should call the success completion block", ^{
                successWasCalled should be_truthy;
            });

            it(@"should not call the failure block", ^{
                failureMessage should be_nil;
            });
        });

        context(@"when the fetch attempt yields a failure", ^{
            beforeEach(^{
                response = makeResponse(500);
                responseData = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
            });

            it(@"should not call the success block", ^{
                successWasCalled should_not be_truthy;
            });

            it(@"should call the failure block with an error", ^{
                failureMessage should_not be_nil;
            });

            it(@"should not change the user messages collection", ^{
                user.messages should be_empty;
            });
        });
    });

    describe(@"-signUpWithEmail:password:completion:invalid:error:", ^{
        NSString *email = @"wibble@example.com", *password = @"password123";

        subjectAction(^{
            [user signUpWithEmail:email password:password success:success failure:failure];
            NSURLSessionDataTask *task = noChat.webService.tasks.firstObject;
            [task completeWithResponse:response data:responseData error:nil];
        });

        beforeEach(^{
            successWasCalled = NO;
            failureMessage = nil;

            success = [^() { successWasCalled = YES; } copy];
            failure = [^(NSError *error) { failureMessage = [error localizedDescription]; } copy];

            spy_on(noChat.webService);
        });

        it(@"should POST to /users", ^{
            noChat.webService should have_received("POST:parameters:completion:invalid:error:");
        });

        it(@"should send the email and password to the server", ^{
            [[(id<CedarDouble>)noChat.webService sent_messages] firstObject];
        });

        context(@"when the signup is successful", ^{
            __block NSUserDefaults *userDefaults;

            beforeEach(^{
                response = makeResponse(201);
                responseData = [NSJSONSerialization dataWithJSONObject:validJSONFromResponseFixtureWithFileName(@"get_fetch_user_response_200.json") options:0 error:nil];
                userDefaults = [NSUserDefaults standardUserDefaults];
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

            it(@"should not call the failure block", ^{
                failureMessage should be_nil;
            });
        });

        context(@"when the signup attempt yields a 422 unprocessable response", ^{
            beforeEach(^{
                response = makeResponse(422);
                responseData = [NSJSONSerialization dataWithJSONObject:@{@"errors": @{@"email": @[@"E-mail is invalid"] } } options:0 error:nil];
            });

            it(@"should not call the success block", ^{
                successWasCalled should_not be_truthy;
            });

            it(@"should call the failure block with an error", ^{
                failureMessage should equal(@"E-mail is invalid");
            });

            it(@"should not change the user messages collection", ^{
                user.messages should be_empty;
            });

            it(@"should notify GA", ^{
                noChat.analytics should have_received("sendAction:withCategory:andError:").with(@"Error Signup", @"Account", Arguments::any([NSError class]));
            });
        });

        context(@"when the signup attempt yields a failure", ^{
            beforeEach(^{
                response = makeResponse(500);
                responseData = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
            });

            it(@"should not call the success block", ^{
                successWasCalled should_not be_truthy;
            });

            it(@"should call the failure block with an error", ^{
                failureMessage should_not be_nil;
            });

            it(@"should not change the user messages collection", ^{
                user.messages should be_empty;
            });

            it(@"should not notify GA", ^{
                noChat.analytics should_not have_received("sendAction:withCategory:andError:");
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

    describe(@"-registerDeviceToken:", ^{
        NSData *deviceToken = [@"nicedevicetoken" dataUsingEncoding:NSUTF8StringEncoding];

        subjectAction(^{
            [user registerDeviceToken:deviceToken];
        });

        context(@"with no device registrations location", ^{
            itShouldRaiseException();
        });

        context(@"with a device registrations location", ^{
            beforeEach(^{
                [user fetchWithSuccess:nil failure:nil];
                NSURLResponse *response = makeResponse(201);
                NSData *responseData = [NSJSONSerialization dataWithJSONObject:validJSONFromResponseFixtureWithFileName(@"get_fetch_user_response_200.json") options:0 error:nil];
                [noChat.webService.tasks.lastObject completeWithResponse:response data:responseData error:nil];
            });

            it(@"should send a request to register the device", ^{
                noChat.webService should have_received("POST:parameters:completion:invalid:error:")
                .with(@"/device_registrations", @{ @"device_token": deviceToken }, nil, nil, nil);
            });
        });
    });
});

SPEC_END

