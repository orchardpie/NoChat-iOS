#import "NCCurrentUser.h"
#import "NoChat.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NCCurrentUserSpec)

describe(@"NCCurrentUser", ^{
    __block NCCurrentUser *user = nil;

    beforeEach(^{
        user = [[NCCurrentUser alloc] init];
    });

    describe(@"-saveCredentialsWithEmail:andPassword:", ^{
        __block __unsafe_unretained NSURLCredential *credential;

        subjectAction(^{ [user saveCredentialsWithEmail:@"kevinwo@orchardpie.com" andPassword:@"whoa"]; });

        beforeEach(^{
            spy_on(noChat.webService);
            noChat.webService stub_method("setCredential:").and_do(^(NSInvocation *invocation) {
                [invocation getArgument:&credential atIndex:2];
            });
        });

        it(@"should save the credentials and set them as the default", ^{
            credential.user should equal(@"kevinwo@orchardpie.com");
            credential.password should equal(@"whoa");
            credential.persistence should equal(NSURLCredentialPersistencePermanent);
        });
    });
});

SPEC_END

