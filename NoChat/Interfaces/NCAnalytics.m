#import "NCAnalytics.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation NCAnalytics

- (instancetype)init
{
    if (self = [super init]) {
        [self initializeGAI];
    }
    return self;
}

- (void)initializeGAI
{
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelNone];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-50103022-1"];

    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [[GAI sharedInstance].defaultTracker set:kGAIAppVersion value:version];
    [[GAI sharedInstance].defaultTracker set:kGAISampleRate value:@"50.0"];
}

- (void)sendAction:(NSString *)action
      withCategory:(NSString *)category
{
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                                                        action:action
                                                                                         label:nil
                                                                                         value:nil]
                                                 build]];
}

@end
