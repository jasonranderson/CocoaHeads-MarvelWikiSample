//
//  NSString+MEExtensions.m
//  MarvelWiki
//
//  Created by Jason Anderson on 12/10/14.
//  Copyright (c) 2014 Jason Anderson. All rights reserved.
//

#import "NSString+MEExtensions.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MEExtensions)

- (NSString *)ME_MD5String {
    const char *str = [self UTF8String];
    
    unsigned char buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(str, (CC_LONG)strlen(str), buffer);
    
    NSMutableString *retval = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++)
        [retval appendFormat:@"%02x",buffer[i]];
    
    return retval;
}

@end
