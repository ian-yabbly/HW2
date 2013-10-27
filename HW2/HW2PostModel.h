//
//  HW2PostModel.h
//  HW2
//
//  Created by Ian Shafer on 10/24/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Post.h"

@protocol HW2PostModel <NSObject>

- (User *)createUserWithEmail:(NSString *)email
                 andFirstName:(NSString *)firstName
                  andLastName:(NSString *)lastName
                  andUsername:(NSString *)username;

- (User *)findUserByUsername:(NSString *)username;
- (NSArray *)findAllUsers;
- (Post *)createPostWithAuthor:(User *)author andTitle:(NSString *)title andBody:(NSString *)body;
- (void)deletePost:(Post *)post;
- (void)updatePost:(Post *)post;
- (NSArray *)findAllPosts;
- (NSArray *)findAllPostsWithOffset:(NSInteger *)offset andLimit:(NSInteger *)limit;

@end
