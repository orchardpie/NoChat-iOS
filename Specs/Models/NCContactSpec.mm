#import "NCContact.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCContactSpec)

describe(@"NCContact", ^{
    __block NCContact *contact;
    __block NSString *firstName;
    __block NSString *lastName;
    __block NSArray *emails;

    beforeEach(^{
        firstName = @"Cool";
        lastName = @"Dude";
        emails = @[@"cooldude@cooltimes.com"];
    });

    describe(@"-initWithFirstName:lastName:emails", ^{
        subjectAction(^{ contact = [[NCContact alloc] initWithFirstName:firstName lastName:lastName emails:emails]; });

        it(@"should set the first name", ^{
            contact.firstName should_not be_nil;
        });

        it(@"should set the last name", ^{
            contact.lastName should_not be_nil;
        });

        it(@"should set the emails", ^{
            contact.emails.count should equal(1);
        });
    });
});

SPEC_END
