#import "NCContactsTableViewController.h"
#import "NoChat.h"
#import "NCAddressBook+Spec.h"
#import "NCContact.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

// Ignore "Unknown selector may cause a leak" warning.  We use performSelector: to
// invoke IBActions, which we know return void.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

SPEC_BEGIN(NCContactsTableViewControllerSpec)

describe(@"NCContactsTableViewController", ^{
    __block NCContactsTableViewController *controller;
    __block id<NCContactsTableViewControllerDelegate> delegate;
    __block NCContact *contact1;
    __block NCContact *contact2;

    beforeEach(^{
        contact1 = [[NCContact alloc] initWithFirstName:@"Cool" lastName:@"Dude" emails:@[@"cooldude@cooltimes.com"]];
        contact2 = [[NCContact alloc] initWithFirstName:@"Gary" lastName:@"Busey" emails:@[@"gary@busey.com"]];
        [noChat.addressBook addContact:contact1];
        [noChat.addressBook addContact:contact2];

        delegate = nice_fake_for(@protocol(NCContactsTableViewControllerDelegate));
        controller = [[NCContactsTableViewController alloc] initWithDelegate:delegate];
        controller.view should_not be_nil;
    });

    describe(@"-viewDidLoad", ^{
        context(@"when the user has contacts", ^{
            it(@"should not show the no results view", ^{
                __block UILabel *labelView;
                [controller.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[UILabel class]]) {
                        labelView = obj;
                        *stop = YES;
                    }
                }];

                labelView should be_nil;
            });
        });

        context(@"when the user has no contacts", ^{
            beforeEach(^{
                [noChat.addressBook removeAllContacts];
                controller = [[NCContactsTableViewController alloc] initWithDelegate:delegate];
                controller.view should_not be_nil;
            });

            it(@"should show the no results view", ^{
                __block UILabel *labelView;
                [controller.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[UILabel class]]) {
                        labelView = obj;
                        *stop = YES;
                    }
                }];

                labelView should_not be_nil;
            });
        });
    });

    describe(@"-close:", ^{
        __block UIBarButtonItem *closeButton;

        subjectAction(^{
            [closeButton.target performSelector:closeButton.action withObject:closeButton];
        });

        beforeEach(^{
            closeButton = controller.navigationItem.leftBarButtonItem;
        });

        it(@"should ask the delegate to close the contacts modal", ^{
            delegate should have_received("didCloseContactsModal");
        });
    });

    describe(@"-tableView:tableView:cellForRowAtIndexPath:", ^{
        __block UITableViewCell *cell;

        subjectAction(^{
            cell = [controller tableView:controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
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

#pragma clang diagnostic pop
