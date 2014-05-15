#import "NCEmailSelectTableViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCEmailSelectTableViewControllerSpec)

describe(@"NCEmailSelectTableViewController", ^{
    __block NCEmailSelectTableViewController *controller;
    __block id<NCEmailSelectTableViewControllerDelegate> delegate;
    __block NSArray *emails;

    beforeEach(^{
        emails = @[@"keanu@reeves.com", @"drwiley@megamancool.com"];
        delegate = nice_fake_for(@protocol(NCEmailSelectTableViewControllerDelegate));
        controller = [[NCEmailSelectTableViewController alloc] initWithEmails:emails delegate:delegate];
        controller.view should_not be_nil;
    });

    describe(@"-tableView:tableView:cellForRowAtIndexPath:", ^{
        __block UITableViewCell *cell;

        subjectAction(^{
            cell = [controller tableView:controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        });

        it(@"should set the email to the textLabel", ^{
            NSString *email = emails.firstObject;
            cell.textLabel.text should equal(email);
        });
    });

    describe(@"-tableView:didSelectRowAtIndexPath:", ^{
        subjectAction(^{
            [controller tableView:controller.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        });

        it(@"should pass the selected contact's email to the delegate", ^{
            delegate should have_received("didSelectEmail:");
        });
    });
});

SPEC_END
