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
                   andImage:(UIImage *)image
                  onSuccess:(void (^)(Post *post))successHandler
{
    [[HW2RestClient singletonInstance] createPostWithTitle:title andBody:body onSuccess:^(NSDictionary *json) {
        // Add this post to the local data store
        NSDictionary *questionDict = [(NSDictionary *) json objectForKey:@"question"];
        NSString *title = [questionDict objectForKey:@"title"];
        NSString *body = [questionDict objectForKey:@"body"];
        NSNumber *postId = [questionDict objectForKey:@"id"];
        
        NSDictionary *image = [questionDict objectForKey:@"image"];
        NSString *imageId = nil;
        if (image) {
            imageId = [image objectForKey:@"external-id"];
        }
        
        // TODO this should be static
        NSDateFormatter *isoDateFormatter = [[NSDateFormatter alloc] init];
        [isoDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSDate *creationDate = [isoDateFormatter dateFromString:[questionDict objectForKey:@"creation-date"]];
        
        [self doWithCurrentUser:^(User *currentUser) {
            Post *createdPost = [[HW2CoreDataPostModel singletonInstance] createPostWithId:postId
                                                                                 andUser:currentUser
                                                                                  andTitle:title
                                                                                   andBody:body
                                                                                andImageId:imageId
                                                                           andCreationDate:creationDate];
            
            if (successHandler) {
                successHandler(createdPost);
            }
        }];
    }];
}

- (void)updatePost:(Post *)post withImage:(UIImage *)image
{
    [[HW2CoreDataPostModel singletonInstance] updatePost:post];
    [[HW2RestClient singletonInstance] updatePost:post withImage:image onSuccess:^(NSDictionary *json) {
        NSDictionary *questionJson = [json objectForKey:@"question"];
        NSDictionary *imageJson = [questionJson objectForKey:@"image"];
        if (imageJson) {
            NSString *imageId = [imageJson objectForKey:@"external-id"];
            // TODO Race condition
            post.imageId = imageId;
            NSLog(@"Updating post [%@] image ID [%@]", post.postId, imageId);
            [[HW2CoreDataPostModel singletonInstance] updatePost:post];
        }
    }];
}

- (void)deletePost:(Post *)post
{
    [[HW2RestClient singletonInstance] deletePost:post onSuccess:^(Post *deletedPost) {
        // Do nothing
    }];
    [[HW2CoreDataPostModel singletonInstance] deletePost:post];
}

- (void)getSquareUserImageForUser:(NSNumber *)userId
                        withWidth:(NSNumber *)width
                        onSuccess:(void (^)(UIImage *image))successHandler
{
    [[HW2RestClient singletonInstance] getSquareUserImageForUser:userId withWidth:width onSuccess:successHandler];
}

- (void)getSquareImageById:(NSString *)imageId
                 withWidth:(NSNumber *)width
                 onSuccess:(void (^)(UIImage *image))successHandler
{
    [[HW2RestClient singletonInstance] getSquareImageById:imageId withWidth:width onSuccess:successHandler];
}

- (void)doWithCurrentUser:(void (^)(User *))fn
{
    User *user = [[HW2CoreDataPostModel singletonInstance] findUserById:[NSNumber numberWithLong:1l]];
    if (user) {
        fn(user);
    } else {
        [[HW2RestClient singletonInstance] findUserById:1l onSuccess:^(NSDictionary *json) {
            NSString *email = [json objectForKey:@"email"];
            NSString *firstName = [json objectForKey:@"first-name"];
            NSString *lastName = [json objectForKey:@"last-name"];
            NSString *name = [json objectForKey:@"name"];
            NSNumber *userId = [json objectForKey:@"id"];
            
            NSDictionary *image = [json objectForKey:@"image"];
            NSString *imageId = nil;
            if (image) {
                imageId = [image objectForKey:@"external-id"];
            }
            
            User *createdUser = [[HW2CoreDataPostModel singletonInstance] createUserWithId:userId
                                                                                  andEmail:email
                                                                              andFirstName:firstName
                                                                               andLastName:lastName
                                                                                   andName:name
                                                                                andImageId:imageId];
            fn(createdUser);
        }];
    }
}

- (void)loadJsonPostsToCoreData:(NSDictionary *)json
{
    NSArray *jsonPosts = [json objectForKey:@"values"];
    for (NSDictionary *jsonPost in jsonPosts) {
        NSNumber *postId = [jsonPost objectForKey:@"id"];
        NSString *title = [jsonPost objectForKey:@"title"];
        NSString *body = [jsonPost objectForKey:@"body"];
        
        // TODO this should be static
        NSDateFormatter *isoDateFormatter = [[NSDateFormatter alloc] init];
        [isoDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSString *jsonCreationDate = [jsonPost objectForKey:@"creation-date"];
        NSDate *creationDate = [isoDateFormatter dateFromString:jsonCreationDate];
        
        NSDictionary *userJson = [jsonPost objectForKey:@"user"];
        NSNumber *userId = [userJson objectForKey:@"id"];
        User *user = [[HW2CoreDataPostModel singletonInstance] findUserById:userId];
        if (!user) {
            user = [self loadJsonUserToCoreData:userJson];
        }
        
        NSDictionary *image = [jsonPost objectForKey:@"image"];
        NSString *imageId = nil;
        if (image) {
            imageId = [image objectForKey:@"external-id"];
        }

        Post *localPost = [[HW2CoreDataPostModel singletonInstance] findPostById:postId.longValue];
        if (localPost) {
            localPost.title = title;
            localPost.body = body;
            localPost.imageId = imageId;
            
            [[HW2CoreDataPostModel singletonInstance] updatePost:localPost];
        } else {
            [[HW2CoreDataPostModel singletonInstance] createPostWithId:postId
                                                               andUser:user
                                                              andTitle:title
                                                               andBody:body
                                                            andImageId:imageId
                                                       andCreationDate:creationDate];
        }
    }
}

- (User *)loadJsonUserToCoreData:(NSDictionary *)json
{
    NSString *email = [json objectForKey:@"email"];
    NSString *firstName = [json objectForKey:@"first-name"];
    NSString *lastName = [json objectForKey:@"last-name"];
    NSString *name = [json objectForKey:@"name"];
    NSNumber *userId = [json objectForKey:@"id"];
    
    NSDictionary *image = [json objectForKey:@"image"];
    NSString *imageId = nil;
    if (image) {
        imageId = [image objectForKey:@"external-id"];
    }
    
    return [[HW2CoreDataPostModel singletonInstance] createUserWithId:userId
                                                             andEmail:email
                                                         andFirstName:firstName
                                                          andLastName:lastName
                                                              andName:name
                                                           andImageId:imageId];
}

@end
