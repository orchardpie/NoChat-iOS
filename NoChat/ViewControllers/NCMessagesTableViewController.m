#import "NCMessagesTableViewController.h"
#import "NCComposeMessageViewController.h"
#import "NCMessage.h"
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

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
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
