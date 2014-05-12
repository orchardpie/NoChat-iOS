#import "NCContactsTableViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCContactsTableViewControllerSpec)

describe(@"NCContactsTableViewController", ^{
    __block NCContactsTableViewController *controller;

    beforeEach(^{
        controller = [[NCContactsTableViewController alloc] init];
    });
});

SPEC_END
