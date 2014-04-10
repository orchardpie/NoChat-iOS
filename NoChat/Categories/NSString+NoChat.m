//
//  NSString+NC.m
//  NCFoundation
//
//  Created by Kevin Wolkober on 8/28/13.
//  Copyright (c) 2013 iOS Developer. All rights reserved.
//

#import "NSString+NoChat.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (NC)

- (BOOL)nc_isEmpty
{
    if ([self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        return YES;
    
    return NO;
}

- (NSString *)nc_sha1
{
    const char *cStr = [self UTF8String];
    NSData *data = [NSData dataWithBytes:cStr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSString *)nc_md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (BOOL)nc_containsLetters
{
    return ([self rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location != NSNotFound);
}

- (BOOL)nc_containsNumbers
{
    return ([self rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound);
}

- (BOOL)nc_containsSpecialCharacters
{
    NSMutableCharacterSet *lettersAndDecimalDigitsCharacterSet = [NSCharacterSet alphanumericCharacterSet];
    NSCharacterSet *decimalDigitCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
    
    [lettersAndDecimalDigitsCharacterSet formUnionWithCharacterSet:decimalDigitCharacterSet];
    
    return ([self rangeOfCharacterFromSet:[lettersAndDecimalDigitsCharacterSet invertedSet]].location != NSNotFound);
}

@end
