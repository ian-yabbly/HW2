//
//  Post.m
//  HW2
//
//  Created by Ian Shafer on 10/23/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import "Post.h"
#import "User.h"


@implementation Post

@dynamic body;
@dynamic creationDate;
@dynamic title;
@dynamic author;

/*
+ (Post *)initWithAuthor:(User *)author andBody:(NSString *)body andTitle:(NSString *)title
{
    Post *post = [[Post alloc] init];
    
    post.author = author;
    post.body = body;
    post.title = title;
    post.creationDate = [[NSDate alloc] init];
    
    return post;
}
*/

@end
