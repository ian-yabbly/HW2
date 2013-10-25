//
//  HW2PostModel.h
//  HW2
//
//  Created by Ian Shafer on 10/24/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"

@protocol HW2PostModel <NSObject>

- (void)addPostWithAuthor:(User *)author title:(NSString *)title body:(NSString *)body;

@end
