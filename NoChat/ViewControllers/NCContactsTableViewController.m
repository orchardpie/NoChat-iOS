#import "NCContactsTableViewController.h"
#import "NoChat.h"
#import "NCAddressBook.h"
#import "NCContact.h"

static NSString *kCellIdentifier = @"contactCell";

@interface NCContactsTableViewController ()

@property (strong, nonatomic) NSArray *contacts;
@property (weak, nonatomic) id<NCContactsTableViewControllerDelegate> delegate;

@end

@implementation NCContactsTableViewController

- (instancetype)initWithDelegate:(id<NCContactsTableViewControllerDelegate>)delegate
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.contacts = noChat.addressBook.contacts;
        self.delegate = delegate;
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

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.tableFooterView = [UIView new]; // don't show blank rows in table view with no data

    self.title = @"Select Contact";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(close:)];

    if (self.contacts.count == 0) {
        [self showNoResultsView];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];

    NCContact *contact = self.contacts[indexPath.row];

    if (contact.emails.count > 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    cell.textLabel.text = [contact fullName];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NCContact *contact = self.contacts[indexPath.row];
    [self.delegate didSelectContactWithEmail:contact.emails[0]];
}

#pragma mark - Button actions

- (void)close:(id)sender
{
    [self.delegate didCloseContactsModal];
}

#pragma mark - Private interface

- (void)showNoResultsView
{
    UILabel *noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        self.view.frame.size.width,
                                                                        self.view.frame.size.height)];
    noResultsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    noResultsLabel.text = @"No Results";
    noResultsLabel.textColor = UIColor.lightGrayColor;
    noResultsLabel.textAlignment = NSTextAlignmentCenter;
    noResultsLabel.center = self.view.center;

    [self.view addSubview:noResultsLabel];
}

@end
