//
//  NSData+Base64.m
//  HW2
//
//  Created by Ian Shafer on 11/7/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import "NSData+Base64.h"
#import "base64.h"

@implementation NSData (Base64)

- (NSString *)stringByBase64Encoding;
{
    size_t buffer_size = (([self length] * 3 + 2) / 2);
    
    char *buffer = (char *)malloc(buffer_size);
    
    int len = b64_ntop([self bytes], [self length], buffer, buffer_size);
    
    if (len == -1) {
        free(buffer);
        return nil;
    } else{
        return [[NSString alloc] initWithBytesNoCopy:buffer length:len encoding:NSUTF8StringEncoding freeWhenDone:YES];
    }
}

@end
