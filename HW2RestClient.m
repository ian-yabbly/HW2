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
#import "Post.h"

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

- (void)findUserById:(long)userId onSuccess:(void (^)(NSDictionary *json))successHandler
{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@/user/%ld", _baseUrl, userId];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:urlString
                                                                                parameters:nil];
    [request setValue:YABBLY_API_SECRET forHTTPHeaderField:@"x-yabbly-api-key"];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    op.securityPolicy.allowInvalidCertificates = YES;
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        successHandler((NSDictionary *) responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (void)findAllPostsWithOffset:(int)offset
                     andLimit:(int)limit
                    onSuccess:(void (^)(NSDictionary *responseDict))successHandler
                      onError:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))errorHandler
{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@/question?o=%d&l=%d", _baseUrl, offset, limit];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:YABBLY_API_SECRET forHTTPHeaderField:@"x-yabbly-api-key"];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    op.securityPolicy.allowInvalidCertificates = YES;
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"In success");
        NSDictionary *jsonResponse = (NSDictionary *) responseObject;
        if (successHandler) {
            successHandler(jsonResponse);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (errorHandler) {
            errorHandler(operation.request, operation.response, error);
        }
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (void)createSessionForUserWithId:(long) userId onSuccess:(void (^)(NSString *sessionId))successHandler
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
        NSString *sessionId = [jsonDict objectForKey:@"session-id"];
        self.sessionId = sessionId;
        successHandler(sessionId);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (void)doWithUser:(void (^)(User *user))fn
{
    if (_currentUser) {
        fn(_currentUser);
    } else {
        [self createSessionForUserWithId:1l onSuccess:^(NSString *sessionId) {
            fn(_currentUser);
        }];
    }
}

- (void)doWIthSessionId:(void (^)(NSString *sessionId))fn
{
    if (_sessionId) {
        fn(_sessionId);
    } else {
        [self createSessionForUserWithId:1l onSuccess:fn];
    }
}

- (void)createPostWithTitle:(NSString *)title
                   andBody:(NSString *)body
                 onSuccess:(void (^)(NSDictionary *json))successHandler
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
        NSDictionary *json = (NSDictionary *) responseObject;
        
        if (successHandler) {
            successHandler(json);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [[NSOperationQueue mainQueue] addOperation:op];
}

-(void)updatePost:(Post *)post onSuccess:(void (^)(NSDictionary *json))successHandler
{

    [self doWIthSessionId:^(NSString *sessionId) {
        NSString *urlString = [[NSString alloc] initWithFormat:@"%@/question", _baseUrl];
        NSDictionary *parameters = @{@"id": post.postId, @"title": post.title, @"body": post.body};
        
        NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:parameters];
        [request setValue:YABBLY_API_SECRET forHTTPHeaderField:@"x-yabbly-api-key"];
        [request setValue:sessionId forHTTPHeaderField:@"x-yabbly-session-id"];
        
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        op.securityPolicy.allowInvalidCertificates = YES;
        
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (successHandler) {
                successHandler((NSDictionary *) responseObject);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        [[NSOperationQueue mainQueue] addOperation:op];
    }];
}

- (void)deletePost:(Post *)post onSuccess:(void (^)(Post *deletedPost))successHandler
{
    [self doWIthSessionId:^(NSString *sessionId) {
        NSString *urlString = [[NSString alloc] initWithFormat:@"%@/question/%@/retract", _baseUrl, post.postId];
        
        NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"DELETE" URLString:urlString parameters:nil];
        [request setValue:YABBLY_API_SECRET forHTTPHeaderField:@"x-yabbly-api-key"];
        [request setValue:sessionId forHTTPHeaderField:@"x-yabbly-session-id"];
        
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        op.securityPolicy.allowInvalidCertificates = YES;
        
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {            
            if (successHandler) {
                successHandler(post);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        [[NSOperationQueue mainQueue] addOperation:op];
    }];
}

@end
