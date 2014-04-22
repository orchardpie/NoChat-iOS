#import "NCMessageTableViewCell.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCMessageTableViewCellSpec)

describe(@"NCMessageTableViewCell", ^{
    __block NCMessageTableViewCell *cell;

    beforeEach(^{
        cell = [[NSBundle mainBundle] loadNibNamed:@"NCMessageTableViewCell" owner:nil options:nil].firstObject;
    });

    describe(@"outlets", ^{
        describe(@"-timeSavedLabel", ^{
            it(@"should be", ^{
                cell.timeSavedLabel should_not be_nil;
            });
        });
        describe(@"-createdAtLabel", ^{
            it(@"should be", ^{
                cell.createdAtLabel should_not be_nil;
            });
        });
    });
});

SPEC_END
