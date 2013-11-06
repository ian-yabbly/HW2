//
//  HW2RestClient.h
//  HW2
//
//  Created by Ian Shafer on 10/27/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"
#import "Post.h"

@interface HW2RestClient : NSObject

// TODO Can I make this "private"
@property (nonatomic) NSString *baseUrl;
@property (nonatomic) NSString *sessionId;
@property (nonatomic) User *currentUser;

+ (HW2RestClient *)singletonInstance;

- (void)findUserById:(long)userId onSuccess:(void (^)(NSDictionary *json))successHandler;

- (void)findAllPostsWithOffset:(int)offset
                     andLimit:(int)limit
                    onSuccess:(void (^)(NSDictionary *responseDict))successHandler
                      onError:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))errorHandler;

- (void)createSessionForUserWithId:(long)userId onSuccess:(void (^)(NSString *sessionId))successHandler;

- (void)createPostWithTitle:(NSString *)title
                    andBody:(NSString *)body
                  onSuccess:(void (^)(NSDictionary *json))successHandler;

- (void)updatePost:(Post *)post onSuccess:(void (^)(NSDictionary *json))successHandler;

- (void)deletePost:(Post *)post onSuccess:(void (^)(Post *deletedPost))successHandler;

- (void)doWithUser:(void (^)(User *user))fn;

@end
