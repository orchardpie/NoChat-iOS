#import "NCComposeMessageViewController.h"
#import "NCMessage.h"

@interface NCComposeMessageViewController ()

@property (weak, nonatomic) id<NCComposeMessageDelegate> delegate;

@end

@implementation NCComposeMessageViewController

- (instancetype)initWithMessage:(NCMessage *)message delegate:(id)delegate
{
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil]) {
        self.delegate = delegate;
    }
    return self;
}

- (instancetype) init {
    [self doesNotRecognizeSelector:_cmd]; return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setUpMessageBodyTextView];
}

# pragma mark - private

- (void)setUpMessageBodyTextView
{
    self.messageBodyTextView.layer.borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0].CGColor;
    self.messageBodyTextView.layer.borderWidth = 0.5;
}

# pragma mark - button actions

- (IBAction)close:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(composeMessageVCCloseButtonTapped)]) {
        [self.delegate composeMessageVCCloseButtonTapped];
    }
}

@end
