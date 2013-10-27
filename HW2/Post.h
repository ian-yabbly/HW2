//
//  Post.h
//  HW2
//
//  Created by Ian Shafer on 10/23/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "User.h"
#import "Post.h"

@class User;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) User *author;

//+ (Post *)initWithAuthor:(User *)author andBody:(NSString *)body andTitle:(NSString *)title;

@end
