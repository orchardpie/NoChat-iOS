#import "NCMessageTableViewCell.h"
#import "NCMessage.h"
#import "NSDate+NVTimeAgo.h"

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

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *createdAtDate = [formatter dateFromString:message.createdAt];

    self.createdAtLabel.text = [createdAtDate formattedAsTimeAgo];
    self.timeSavedLabel.text = message.timeSavedDescription;
}

@end
