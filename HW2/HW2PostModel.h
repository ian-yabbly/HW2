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

- (User *)createUserWithId:(NSNumber *)userId
                  andEmail:(NSString *)email
              andFirstName:(NSString *)firstName
               andLastName:(NSString *)lastName
                   andName:(NSString *)name
                andImageId:(NSString *)imageId;

- (User *)findUserByName:(NSString *)name;
- (User *)findUserById:(NSNumber *)userId;
- (NSArray *)findAllUsers;

- (Post *)createPostWithId:(NSNumber *)postId
                 andUser:(User *)user
                  andTitle:(NSString *)title
                   andBody:(NSString *)body
                andImageId:(NSString *)imageId
           andCreationDate:(NSDate *)creationDate;

- (void)deletePost:(Post *)post;
- (void)updatePost:(Post *)post;
- (Post *)findPostById:(long)postId;
- (NSArray *)findAllPosts;
- (NSArray *)findAllPostsWithOffset:(NSInteger *)offset andLimit:(NSInteger *)limit;

@end
