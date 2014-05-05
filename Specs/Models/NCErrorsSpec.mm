#import "NCErrors.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCErrorsSpec)

describe(@"NCErrors", ^{
    __block NCErrors *errors;
    __block id obj;

    describe(@"-initWithJSONObject:", ^{
        NSString *message = @"Please don't be stupid";

        subjectAction(^{
            errors = [[NCErrors alloc] initWithJSONObject:obj];
        });

        context(@"with valid error JSON", ^{
            beforeEach(^{
                obj = @{ @"errors": @{ @"email": @[message] } };
            });

            it(@"should generate an error with the message as the localized description", ^{
                errors.error.localizedDescription should equal(message);
            });
        });

        context(@"with valid error JSON with multiple errors", ^{
            beforeEach(^{
                obj = @{ @"errors": @{ @"email": @[message, @"anything"], @"body": @[@"yet more anything"] } };
            });

            it(@"should generate an error with the first message as the localized description", ^{
                errors.error.localizedDescription should equal(message);
            });
        });

        context(@"with valid error JSON with no errors", ^{
            beforeEach(^{
                obj = @{ @"errors": @{} };
            });

            it(@"should set error to nil", ^{
                errors.error should be_nil;
            });
        });

        context(@"with garbage JSON", ^{
            beforeEach(^{
                obj = @"totaluttergarbage";
            });

            it(@"should set error to nil", ^{
                errors.error should be_nil;
            });
        });

        context(@"with no JSON", ^{
            beforeEach(^{
                obj = nil;
            });

            it(@"should set error to nil", ^{
                errors.error should be_nil;
            });
        });

        context(@"with valid JSON that does not contain errors", ^{
            beforeEach(^{
                obj = @{ @"problemas": @{ @"email": @[message, @"anything"], @"body": @[@"yet more anything"] } };
            });

            it(@"should set error to nil", ^{
                errors.error should be_nil;
            });
        });
    });
});

SPEC_END
