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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... {
    if (self = [super init]) {
        self.title = title;
        self.message = message;
    }
    return self;
}

- (void)show
{
    self.class.currentAlertView = self;
}

@end
