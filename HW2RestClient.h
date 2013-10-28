//
//  HW2RestClient.h
//  HW2
//
//  Created by Ian Shafer on 10/27/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HW2PostUpdateDelegate.h"
#import "User.h"

@interface HW2RestClient : NSObject

// TODO Can I make this "private"
@property (nonatomic) NSString *baseUrl;
@property (nonatomic) NSString *sessionId;
@property (nonatomic) User *currentUser;
@property (nonatomic) id<HW2PostUpdateDelegate> postUpdateDelegate;

+ (HW2RestClient *)singletonInstance;

-(void)findAllPostsWithOffset:(int)offset
                     andLimit:(int)limit
                    onSuccess:(void (^)(NSArray *posts))successHandler/*
                                                                                                                    onError:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))errorHandler*/;

-(void)createSessionForUserWithId:(long) userId onSuccess:(void (^)(NSString *sessionId))successHandler;

-(void)createPostWithTitle:(NSString *)title
                    andBody:(NSString *)body
                  onSuccess:(void (^)(Post *post))successHandler;

-(void)updatePost:(Post *)post onSuccess:(void (^)(Post *updatedPost))successHandler;

@end
