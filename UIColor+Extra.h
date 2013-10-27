//
//  UIColor+Extra.h
//  HW2
//
//  Created by Ian Shafer on 10/26/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extra)

+ (UIColor *)random;

+ (UIColor *)lightenColor:(UIColor *)color;

+ (UIColor *)lightenColor:(UIColor *)color byFactor:(float)factor;

@end
