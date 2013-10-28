//
//  HW2RestClient.m
//  HW2
//
//  Created by Ian Shafer on 10/27/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"
#import "HW2RestClient.h"
#import "HW2CoreDataPostModel.h"

#define YABBLY_API_SECRET @"S8Cj4G9bGFV5oxDHAwYrRjYdn5E9aEjl"
#define YABBLY_API_VERSION @"1.1"
#define YABBLY_API_HOST @"q.yabbly.com"
#define YABBLY_API_URL_CONTEXT @"/rest"
#define YABBLY_API_PROTOCOL @"https"

@implementation HW2RestClient

+ (HW2RestClient *)singletonInstance
{
    static dispatch_once_t pred;
    static HW2RestClient *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[HW2RestClient alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    id v = [super init];
    
    _baseUrl = [[NSString alloc] initWithFormat:@"%@://%@%@/%@",
                YABBLY_API_PROTOCOL,
                YABBLY_API_HOST,
                YABBLY_API_URL_CONTEXT,
                YABBLY_API_VERSION];
    
    return v;
}

-(void)findAllPostsWithOffset:(int)offset
                     andLimit:(int)limit
                    onSuccess:(void (^)(NSArray *posts))successHandler/*
                                                                                                                    onError:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))errorHandler*/
{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@/question?o=%d&l=%d", _baseUrl, offset, limit];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:YABBLY_API_SECRET forHTTPHeaderField:@"x-yabbly-api-key"];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    op.securityPolicy.allowInvalidCertificates = YES;
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonResponse = (NSDictionary *) responseObject;
        NSArray *jsonPosts = [jsonResponse objectForKey:@"values"];
        NSMutableArray *posts = [[NSMutableArray alloc] init];
        for (NSDictionary *jsonPost in jsonPosts) {
            NSNumber *postId = [jsonPost objectForKey:@"id"];
            Post *localPost = [[HW2CoreDataPostModel singletonInstance] findPostById:postId.longValue];
            if (localPost) {
                [posts addObject:localPost];
            } else {
                // TODO this should be static
                NSDateFormatter *isoDateFormatter = [[NSDateFormatter alloc] init];
                [isoDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                NSString *title = [jsonPost objectForKey:@"title"];
                NSString *body = [jsonPost objectForKey:@"body"];
                NSString *jsonCreationDate = [jsonPost objectForKey:@"creation-date"];
                NSDate *creationDate = [isoDateFormatter dateFromString:jsonCreationDate];
                localPost = [[HW2CoreDataPostModel singletonInstance] createPostWithId:postId.longValue andAuthor:_currentUser andTitle:title andBody:body andCreationDate:creationDate];
                [posts addObject:localPost];
                [_postUpdateDelegate postWasCreated:localPost];
            }
        }
        if (successHandler) {
            successHandler(posts);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}

-(void)createSessionForUserWithId:(long) userId onSuccess:(void (^)(NSString *sessionId))successHandler
{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@/dev/switch-user/%ld", _baseUrl, userId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:YABBLY_API_SECRET forHTTPHeaderField:@"x-yabbly-api-key"];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    op.securityPolicy.allowInvalidCertificates = YES;
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        NSDictionary *userDict = (NSDictionary *) [jsonDict objectForKey:@"user"];
        NSString *sessionId = [jsonDict objectForKey:@"session-id"];
        [self setSessionId:sessionId];
        
        User *foundUser = [[HW2CoreDataPostModel singletonInstance] findUserById:userId];
        if (foundUser) {
            [self setCurrentUser:foundUser];
        } else {
            NSString *email = [userDict objectForKey:@"email"];
            NSString *firstName = [userDict objectForKey:@"first-name"];
            NSString *lastName = [userDict objectForKey:@"last-name"];
            NSString *username = [userDict objectForKey:@"name"];
            
            User *createdUser = [[HW2CoreDataPostModel singletonInstance] createUserWithEmail:email
                                                             andFirstName:firstName
                                                              andLastName:lastName
                                                              andUsername:username];
            [self setCurrentUser:createdUser];
        }
        successHandler(sessionId);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}

-(void)createPostWithTitle:(NSString *)title
                   andBody:(NSString *)body
                 onSuccess:(void (^)(Post *post))successHandler
{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@/question", _baseUrl];
    NSDictionary *parameters = @{@"title": title, @"body": body, @"tags": @[@"Other"]};
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters];
    [request setValue:YABBLY_API_SECRET forHTTPHeaderField:@"x-yabbly-api-key"];
    [request setValue:_sessionId forHTTPHeaderField:@"x-yabbly-session-id"];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    op.securityPolicy.allowInvalidCertificates = YES;
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Add this post to the local data store
        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        NSDictionary *questionDict = [(NSDictionary *) jsonDict objectForKey:@"question"];
        NSString *title = [questionDict objectForKey:@"title"];
        NSString *body = [questionDict objectForKey:@"body"];
        NSNumber *postId = [questionDict objectForKey:@"id"];
        
        // TODO this should be static
        NSDateFormatter *isoDateFormatter = [[NSDateFormatter alloc] init];
        [isoDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSDate *creationDate = [isoDateFormatter dateFromString:[questionDict objectForKey:@"creation-date"]];

        Post *createdPost = [[HW2CoreDataPostModel singletonInstance] createPostWithId:postId.longValue
                                                                             andAuthor:_currentUser
                                                                              andTitle:title
                                                                               andBody:body
                                                                       andCreationDate:creationDate];
        successHandler(createdPost);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}

-(void)updatePost:(Post *)post onSuccess:(void (^)(Post *updatedPost))successHandler
{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@/question", _baseUrl];
    NSDictionary *parameters = @{@"id": post.id, @"title": post.title, @"body": post.body};
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters];
    [request setValue:YABBLY_API_SECRET forHTTPHeaderField:@"x-yabbly-api-key"];
    [request setValue:_sessionId forHTTPHeaderField:@"x-yabbly-session-id"];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    op.securityPolicy.allowInvalidCertificates = YES;
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[HW2CoreDataPostModel singletonInstance] updatePost:post];
        
        if (successHandler) {
            successHandler(post);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}

@end
