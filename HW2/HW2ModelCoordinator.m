//
//  HW2ModelCoordinator.m
//  HW2
//
//  Created by Ian Shafer on 11/4/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import "HW2ModelCoordinator.h"
#import "HW2CoreDataPostModel.h"
#import "HW2RestClient.h"
#import "User.h"
#import "Post.h"

@implementation HW2ModelCoordinator

+ (HW2ModelCoordinator *)singletonInstance
{
    static dispatch_once_t pred;
    static HW2ModelCoordinator *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[HW2ModelCoordinator alloc] init];
    });
    return sharedInstance;
}

- (NSFetchedResultsController *)findAllPostsInFetchedResultsController
{
    [[HW2RestClient singletonInstance] findAllPostsWithOffset:0
                                                     andLimit:100
                                                    onSuccess:^(NSDictionary *json) {
                                                        [self loadJsonPostsToCoreData:json];
                                                    }
                                                      onError:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                          NSLog(@"Error retrieving posts [%@]", error.description);
                                                      }];
    return [[HW2CoreDataPostModel singletonInstance] findAllPostsInFetchedResultsController];
}

- (void)createPostWithTitle:(NSString *)title
                    andBody:(NSString *)body
                  onSuccess:(void (^)(Post *post))successHandler
{
    [[HW2RestClient singletonInstance] createPostWithTitle:title andBody:body onSuccess:^(NSDictionary *json) {
        // Add this post to the local data store
        NSDictionary *questionDict = [(NSDictionary *) json objectForKey:@"question"];
        NSString *title = [questionDict objectForKey:@"title"];
        NSString *body = [questionDict objectForKey:@"body"];
        NSNumber *postId = [questionDict objectForKey:@"id"];
        
        // TODO this should be static
        NSDateFormatter *isoDateFormatter = [[NSDateFormatter alloc] init];
        [isoDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSDate *creationDate = [isoDateFormatter dateFromString:[questionDict objectForKey:@"creation-date"]];
        
        [self doWithCurrentUser:^(User *currentUser) {
            Post *createdPost = [[HW2CoreDataPostModel singletonInstance] createPostWithId:postId
                                                                                 andUser:currentUser
                                                                                  andTitle:title
                                                                                   andBody:body
                                                                           andCreationDate:creationDate];
            
            if (successHandler) {
                successHandler(createdPost);
            }
        }];
    }];
}

- (void)updatePost:(Post *)post
{
    [[HW2CoreDataPostModel singletonInstance] updatePost:post];
    [[HW2RestClient singletonInstance] updatePost:post onSuccess:nil];
}

- (void)deletePost:(Post *)post
{
    [[HW2RestClient singletonInstance] deletePost:post onSuccess:^(Post *deletedPost) {
        // Do nothing
    }];
    [[HW2CoreDataPostModel singletonInstance] deletePost:post];
}

- (void)doWithCurrentUser:(void (^)(User *))fn
{
    User *user = [[HW2CoreDataPostModel singletonInstance] findUserById:1l];
    if (user) {
        fn(user);
    } else {
        [[HW2RestClient singletonInstance] findUserById:1l onSuccess:^(NSDictionary *json) {
            NSString *email = [json objectForKey:@"email"];
            NSString *firstName = [json objectForKey:@"first-name"];
            NSString *lastName = [json objectForKey:@"last-name"];
            NSString *name = [json objectForKey:@"name"];
            NSNumber *userId = [json objectForKey:@"id"];
            
            User *createdUser = [[HW2CoreDataPostModel singletonInstance] createUserWithId:userId
                                                                                  andEmail:email
                                                                              andFirstName:firstName
                                                                               andLastName:lastName
                                                                               andName:name];
            fn(createdUser);
        }];
    }
}

- (void)loadJsonPostsToCoreData:(NSDictionary *)json
{
    NSArray *jsonPosts = [json objectForKey:@"values"];
    for (NSDictionary *jsonPost in jsonPosts) {
        NSNumber *postId = [jsonPost objectForKey:@"id"];
        Post *localPost = [[HW2CoreDataPostModel singletonInstance] findPostById:postId.longValue];
        if (!localPost) {
            // TODO this should be static
            NSDateFormatter *isoDateFormatter = [[NSDateFormatter alloc] init];
            [isoDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
            NSString *title = [jsonPost objectForKey:@"title"];
            NSString *body = [jsonPost objectForKey:@"body"];
            NSString *jsonCreationDate = [jsonPost objectForKey:@"creation-date"];
            NSDate *creationDate = [isoDateFormatter dateFromString:jsonCreationDate];
            
            
            [[HW2RestClient singletonInstance] doWithUser:^(User *user) {
                [[HW2CoreDataPostModel singletonInstance] createPostWithId:postId
                                                                   andUser:user
                                                                  andTitle:title
                                                                   andBody:body
                                                           andCreationDate:creationDate];
            }];
        }
    }
}

@end
