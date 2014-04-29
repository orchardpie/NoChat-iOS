#ifndef NoChat_NCSpecHelper_h
#define NoChat_NCSpecHelper_h
#import "Cedar/SpecHelper.h"
#import <Foundation/Foundation.h>

extern NSHTTPURLResponse *makeResponse(int statusCode);
extern NSData *dataFromResponseFixtureWithFileName(NSString *fileName);
extern id validJSONFromResponseFixtureWithFileName(NSString *fileName);

#endif
