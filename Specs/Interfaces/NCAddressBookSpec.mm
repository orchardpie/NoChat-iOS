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

        describe(@"order", ^{
            __block NCContact *contact1;
            __block NCContact *contact2;

            beforeEach(^{
                contact2 = [[NCContact alloc] initWithFirstName:@"Barack" lastName:@"Obama" emails:@[@"yournewbicycle@whitehouse.gov"]];
                [addressBook addContact:contact2];

                contact1 = [[NCContact alloc] initWithFirstName:@"Abe" lastName:@"Lincoln" emails:@[@"abe@orchardpie.com"]];
                [addressBook addContact:contact1];
            });

            it(@"should order alphabetically by first name", ^{
                [addressBook.contacts.firstObject firstName] should equal(contact1.firstName);
                [addressBook.contacts.lastObject firstName] should equal(contact2.firstName);
            });
        });
    });
});

SPEC_END
