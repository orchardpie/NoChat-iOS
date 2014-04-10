//
//  NSString+AO.h
//  AOFoundation
//
//  Created by Kevin Wolkober on 8/28/13.
//  Copyright (c) 2013 iOS Developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AO)

/**
 Check a string to see if it is truly empty (i.e. either contains no characters or only spaces)
 */
- (BOOL)nc_isEmpty;

/**
 Generate a SHA1-encrypted NSString
 
 @return A SHA1-encrypted NSString
 */
- (NSString *)nc_sha1;

/**
 Generate an MD5 hash of an NSString
 
 @return An MD5 hash of an NSString
 */
- (NSString *)nc_md5;

- (BOOL)nc_containsLetters;

- (BOOL)nc_containsNumbers;

- (BOOL)nc_containsSpecialCharacters;

@end
