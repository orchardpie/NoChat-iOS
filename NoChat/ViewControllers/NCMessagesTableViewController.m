#import "NCMessagesTableViewController.h"
#import "NCComposeMessageViewController.h"
#import "NCMessagesCollection.h"
#import "NCMessage.h"
#import "NCMessageTableViewCell.h"
#import "NoChat.h"
#import "NCAnalytics.h"
#import "MBProgressHUD.h"

@interface NCMessagesTableViewController ()

@property (strong, nonatomic) NCMessagesCollection *messages;

@end

@implementation NCMessagesTableViewController

- (instancetype)initWithMessages:(NCMessagesCollection *)messages
{
    if (self = [super init]) {
        self.messages = messages;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd]; return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Chats";
    [self.tableView registerNib:[UINib nibWithNibName:@"NCMessageTableViewCell" bundle:nil] forCellReuseIdentifier:NCMessageTableViewCell.cellIdentifier];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeMessage:)];

    [self enablePullToRefresh];
}

- (void)refreshMessagesWithIndicator
{
    [self.refreshControl beginRefreshing];
    [self refreshMessages];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Table view delegate implementation

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NCMessageTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NCMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NCMessageTableViewCell cellIdentifier]];

    NCMessage *message = [self.messages objectAtIndex:indexPath.row];
    cell.message = message;

    return cell;
}

#pragma mark - UIBarButtonItem actions

- (void)composeMessage:(id)sender
{
    [noChat.analytics sendAction:@"Create Message" withCategory:@"Messages"];
    NCMessage *message = [[NCMessage alloc] init];
    NCComposeMessageViewController *composeMessageVC = [[NCComposeMessageViewController alloc] initWithMessage:message
                                                        delegate:self];
    [self presentViewController:composeMessageVC animated:YES completion:nil];
}

#pragma mark - NCComposeMessageViewController delegate methods

- (void)composeMessageVCCloseButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidSendMessage:(NCMessage *)message
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Private interface

- (void)refreshMessages {
    [self.messages fetchWithSuccess:^{
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.refreshControl endRefreshing];
        [[[UIAlertView alloc] initWithTitle:@"Messages could not be retrieved"
                                    message:@"Please ensure you are connected to the Internet and try again."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    }];
}

- (void)enablePullToRefresh
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshMessages) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

@end
