#import "NCMessageTableViewCell.h"
#import "NCMessage.h"

@implementation NCMessageTableViewCell

+ (NSString *)cellIdentifier
{
    return NSStringFromClass([self class]);
}

+ (CGFloat)cellHeight
{
    return 64.0;
}

- (void)prepareForReuse
{
    self.createdAtLabel.text = @"";
    self.timeSavedLabel.text = @"";
    _message = nil;
}

- (void)setMessage:(NCMessage *)message
{
    _message = message;
    self.createdAtLabel.text = message.createdAt;
    self.timeSavedLabel.text = [NSString stringWithFormat:@"%d seconds saved", [message.timeSaved intValue] / 1000];
}

@end
