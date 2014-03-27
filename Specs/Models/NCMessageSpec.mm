#import "NCMessage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCMessageSpec)

describe(@"NCMessage", ^{
    __block NCMessage *message;
    __block NSDictionary *dictionary;

    beforeEach(^{
        dictionary = @{ @"time_saved": @500, @"disposition": @"sent"};
    });

    subjectAction(^{ message = [[NCMessage alloc] initWithDictionary:dictionary]; });

    it(@"should set time saved in milliseconds", ^{
        message.time_saved should equal(500);
    });

    it(@"should set disposition", ^{
        message.disposition should equal(@"sent");
    });
});

SPEC_END
