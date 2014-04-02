#import "UIAlertView+Spec.h"

static UIAlertView *__currentAlertView;

@implementation UIAlertView (Spec)

+ (instancetype)currentAlertView
{
    return __currentAlertView;
}

+ (void)setCurrentAlertView:(UIAlertView *)alertView
{
    __currentAlertView = alertView;
}

- (void)show
{
    UIAlertView *alertView = [[self.class alloc] init];
    self.class.currentAlertView = alertView;
}

@end
