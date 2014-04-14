#import "NCMessagesTableViewController.h"
#import "NCComposeMessageViewController.h"

@interface NCMessagesTableViewController ()

@end

@implementation NCMessagesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Chats";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeMessage:)];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - UIBarButtonItem actions

- (void)composeMessage:(id)sender
{
    NCComposeMessageViewController *composeMessageVC = [[NCComposeMessageViewController alloc] initWithMessage:nil
                                                        delegate:self];
    [self presentViewController:composeMessageVC animated:YES completion:nil];
}

#pragma mark - NCComposeMessageViewController delegate methods

- (void)composeMessageVCCloseButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
