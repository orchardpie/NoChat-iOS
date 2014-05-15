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

    describe(@"-fullName", ^{
        context(@"when the contact has both a first name and last name", ^{
            beforeEach(^{
                contact = [[NCContact alloc] initWithFirstName:@"Barack" lastName:@"Obama" emails:@[@"barry@whitehouse.gov"]];
            });

            it(@"should be their first and last name", ^{
                contact.fullName should equal(@"Barack Obama");
            });
        });

        context(@"when the contact has only a first name", ^{
            beforeEach(^{
                contact = [[NCContact alloc] initWithFirstName:@"Barack" lastName:nil emails:@[@"barry@whitehouse.gov"]];
            });

            it(@"should be their first name", ^{
                contact.fullName should equal(@"Barack");
            });
        });

        context(@"when the contact has only a last name", ^{
            beforeEach(^{
                contact = [[NCContact alloc] initWithFirstName:nil lastName:@"Obama" emails:@[@"barry@whitehouse.gov"]];
            });

            it(@"should be their last name", ^{
                contact.fullName should equal(@"Obama");
            });
        });

        context(@"when the contact has neither first name nor last name", ^{
            beforeEach(^{
                contact = [[NCContact alloc] initWithFirstName:nil lastName:nil emails:@[@"barry@whitehouse.gov", @"thebigguy@whitehouse.gov"]];
            });

            it(@"should be their first e-mail", ^{
                contact.fullName should equal(@"barry@whitehouse.gov");
            });
        });
    });
});

SPEC_END
