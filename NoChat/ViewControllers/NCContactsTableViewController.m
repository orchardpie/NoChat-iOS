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

    self.title = @"Select Contact";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(close:)];
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

@end
