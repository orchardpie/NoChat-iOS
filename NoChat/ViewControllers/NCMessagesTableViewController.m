#import "NCMessagesTableViewController.h"
#import "NCComposeMessageViewController.h"
#import "NCMessage.h"
#import "NCMessageTableViewCell.h"
#import "NoChat.h"

@interface NCMessagesTableViewController ()

@property (strong, nonatomic) NSArray *messages;

@end

@implementation NCMessagesTableViewController

- (instancetype)initWithMessages:(NSArray *)messages
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

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeMessage:)];
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

    NCMessage *message = self.messages[indexPath.row];
    cell.message = message;

    return cell;
}

#pragma mark - UIBarButtonItem actions

- (void)composeMessage:(id)sender
{
    NCMessage *message = [[NCMessage alloc] init];
    NCComposeMessageViewController *composeMessageVC = [[NCComposeMessageViewController alloc] initWithMessage:message
                                                        delegate:self];
    [self presentViewController:composeMessageVC animated:YES completion:nil];
}

- (void)logout:(id)sender
{
    [noChat invalidateCurrentUser];
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

@end
