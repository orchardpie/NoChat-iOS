#import "NCMessageTableViewCell.h"
#import "NCMessage.h"

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

    describe(@"-prepareForReuse", ^{
        __block NCMessage *message;

        subjectAction(^{ [cell prepareForReuse]; });

        beforeEach(^{
            message = [[NCMessage alloc] initWithDictionary:@{@"time_saved_description": @"666 seconds saved", @"created_at": @"7 hours ago"}];
            [cell setMessage:message];
        });

        it(@"should set the created at label text to blank", ^{
            cell.createdAtLabel.text should be_empty;
        });

        it(@"should set the time saved label text to blank", ^{
            cell.timeSavedLabel.text should be_empty;
        });

        it(@"should set message to nil", ^{
            cell.message should be_nil;
        });
    });

    describe(@"-setMessage:", ^{
        __block NCMessage *message;

        subjectAction(^{ cell.message = message; });

        beforeEach(^{
            message = [[NCMessage alloc] initWithDictionary:@{@"time_saved_description": @"666 seconds saved", @"created_at": @"7 hours ago"}];
        });

        it(@"should set the time saved label", ^{
            cell.timeSavedLabel.text should equal(@"666 seconds saved");
        });

        it(@"should set the created at label", ^{
            cell.createdAtLabel.text should equal(@"7 hours ago");
        });
    });
});

SPEC_END
