#import "MBProgressHUD+Spec.h"

static MBProgressHUD *__currentHUD;

@implementation MBProgressHUD (Spec)

+ (void)afterEach {
    [self.class setCurrentHUD:nil];
}

+ (instancetype)currentHUD {
    return __currentHUD;
}

+ (void)setCurrentHUD:(MBProgressHUD *)hud {
    __currentHUD = hud;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated {
    MBProgressHUD *hud = [[self.class alloc] initWithView:view];
    self.class.currentHUD = hud;
    return hud;
}

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated
{
    self.class.currentHUD = nil;
    return YES;
}

#pragma clang diagnostic pop

@end
