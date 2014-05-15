#import "NCContactsTableViewController.h"
#import "NoChat.h"
#import "NCAddressBook+Spec.h"
#import "NCContact.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCContactsTableViewControllerSpec)

describe(@"NCContactsTableViewController", ^{
    __block NCContactsTableViewController *controller;
    __block id<NCContactsTableViewControllerDelegate> delegate;
    __block NCContact *contact1;
    __block NCContact *contact2;

    beforeEach(^{
        contact1 = [[NCContact alloc] initWithFirstName:@"Cool" lastName:@"Dude" emails:@[@"cooldude@cooltimes.com"]];
        contact2 = [[NCContact alloc] initWithFirstName:@"Gary" lastName:@"Busey" emails:@[@"gary@busey.com"]];
        noChat.addressBook.contacts = @[contact1, contact2];

        delegate = nice_fake_for(@protocol(NCContactsTableViewControllerDelegate));
        controller = [[NCContactsTableViewController alloc] initWithDelegate:delegate];
    });

    describe(@"-tableView:tableView:cellForRowAtIndexPath:", ^{
        __block UITableViewCell *cell;

        subjectAction(^{
            cell = [controller tableView:controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        });

        beforeEach(^{
            controller.view should_not be_nil;
        });

        it(@"should set the name to the textLabel", ^{
            NSString *contactFullName = [NSString stringWithFormat:@"%@ %@", contact1.firstName, contact1.lastName];
            cell.textLabel.text should equal(contactFullName);
        });

        context(@"when a contact has one email", ^{
            it(@"should not show a disclosure indicator", ^{
                cell.accessoryType should_not equal(UITableViewCellAccessoryDisclosureIndicator);
            });
        });

        context(@"when a contact has more than one email", ^{
            beforeEach(^{
                contact1.emails = @[@"neat@email.com", @"fun@email.com"];
            });

            it(@"should show a disclosure indicator", ^{
                cell.accessoryType should equal(UITableViewCellAccessoryDisclosureIndicator);
            });
        });
    });

    describe(@"-tableView:didSelectRowAtIndexPath:", ^{
        subjectAction(^{
            [controller tableView:controller.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        });

        it(@"should pass the selected contact's email to the delegate", ^{
            delegate should have_received("didSelectContactWithEmail:");
        });
    });
});

SPEC_END
