#import "NCAddressBook+Spec.h"
#import "NCContact.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCAddressBookSpec)

describe(@"NCAddressBook", ^{
    __block NCAddressBook *addressBook;

    beforeEach(^{
        addressBook = [[NCAddressBook alloc] init];
    });

    describe(@"-contacts", ^{
        __block NCContact *contact;

        context(@"with a contact that has an email address", ^{
            beforeEach(^{
                contact = [[NCContact alloc] initWithFirstName:@"Barack" lastName:@"Obama" emails:@[@"yournewbicycle@whitehouse.gov"]];
                [addressBook addContact:contact];
            });

            it(@"should contain the contact", ^{
                addressBook.contacts should contain(contact);
            });
        });

        context(@"with a contact that has multiple email addresses", ^{
            beforeEach(^{
                contact = [[NCContact alloc] initWithFirstName:@"Barack" lastName:@"Obama" emails:@[@"yournewbicycle@whitehouse.gov", @"barry@whitehouse.gov"]];
                [addressBook addContact:contact];
            });

            it(@"should contain the contact", ^{
                addressBook.contacts should contain(contact);
            });
        });

        context(@"with a contact that has no email addresses", ^{
            beforeEach(^{
                contact = [[NCContact alloc] initWithFirstName:@"Barack" lastName:@"Obama" emails:@[]];
                [addressBook addContact:contact];
            });

            it(@"should not contain the contact", ^{
                addressBook.contacts should_not contain(contact);
            });
        });
    });
});

SPEC_END
