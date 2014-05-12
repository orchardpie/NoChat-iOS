#import "NCAddressBook.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCAddressBookSpec)

describe(@"NCAddressBook", ^{
    __block NCAddressBook *addressBook;

    beforeEach(^{
        addressBook = [[NCAddressBook alloc] init];
    });

    
});

SPEC_END
