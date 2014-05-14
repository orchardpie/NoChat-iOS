#import "NCContactsTableViewController.h"
#import "NoChat.h"
#import "NCAddressBook.h"
#import "NCContact.h"

static NSString *kCellIdentifier = @"contactCell";

@interface NCContactsTableViewController ()

@property (strong, nonatomic) NSArray *contacts;

@end

@implementation NCContactsTableViewController

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.contacts = noChat.addressBook.contacts;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
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

    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];

    return cell;
}

@end
