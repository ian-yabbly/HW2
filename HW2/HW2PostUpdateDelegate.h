//
//  HW2PostUpdateDelegate.h
//  HW2
//
//  Created by Ian Shafer on 10/26/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Post.h"

@protocol HW2PostUpdateDelegate <NSObject>

-(void) postWasUpdated:(Post *)post;
-(void) postWasCreated:(Post *)post;

@end
