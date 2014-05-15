#import "NCEmailSelectTableViewController.h"

static NSString *kCellIdentifier = @"emailCell";

@interface NCEmailSelectTableViewController ()

@property (strong, nonatomic) NSArray *emails;
@property (weak, nonatomic) id<NCEmailSelectTableViewControllerDelegate> delegate;

@end

@implementation NCEmailSelectTableViewController

- (instancetype)initWithEmails:(NSArray *)emails
              delegate:(id<NCEmailSelectTableViewControllerDelegate>)delegate
{
    if (self == [super init]) {
        self.emails = emails;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.tableFooterView = [UIView new]; // don't show blank rows in table view with no data

    self.title = @"Select Email";
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.emails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.emails[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate didSelectEmail:self.emails[indexPath.row]];
}

@end
