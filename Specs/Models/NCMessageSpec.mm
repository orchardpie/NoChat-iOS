#import "NCMessage.h"
#import "NoChat.h"
#import "NCWebService.h"
#import "NSURLSession+Spec.h"
#import "NSURLSessionDataTask+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;



SPEC_BEGIN(NCMessageSpec)

describe(@"NCMessage", ^{
    __block NCMessage *message;
    __block NSDictionary *dictionary;

    beforeEach(^{
        dictionary = @{ @"id": @42,
                        @"created_at": @"4/14/14",
                        @"time_saved_description": @"666 seconds saved",
                        @"disposition": @"received"
                      };
    });

    describe(@"-initWithDictionary:", ^{
        subjectAction(^{ message = [[NCMessage alloc] initWithDictionary:dictionary]; });

        it(@"should set the ID", ^{
            message.messageId should equal(42);
        });

        it(@"should set the created at date string", ^{
            message.createdAt should equal(@"4/14/14");
        });

        it(@"should set time saved in milliseconds", ^{
            message.timeSavedDescription should equal(@"666 seconds saved");
        });

        it(@"should set the disposition", ^{
            message.disposition should equal(@"received");
        });
    });
});

SPEC_END
