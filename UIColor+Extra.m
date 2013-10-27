//
//  UIColor+Extra.m
//  HW2
//
//  Created by Ian Shafer on 10/26/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import "UIColor+Extra.h"

@implementation UIColor (Extra)

+ (UIColor *)random
{
    return [[UIColor alloc] initWithRed:drand48() green:drand48() blue:drand48() alpha:1.0f];
}

+ (UIColor *)lightenColor:(UIColor *)color
{
    return [self lightenColor:color byFactor:0.9f];
}


+ (UIColor *)lightenColor:(UIColor *)color byFactor:(float)factor
{
    CGFloat *red = nil;
    CGFloat *green = nil;
    CGFloat *blue = nil;
    CGFloat *alpha = nil;
    [color getRed:red green:green blue:blue alpha:alpha];
    
    return [[UIColor alloc] initWithRed:(*red * factor)
                                  green:(*green * factor)
                                   blue:(*blue * factor)
                                  alpha:*alpha];
}

@end
