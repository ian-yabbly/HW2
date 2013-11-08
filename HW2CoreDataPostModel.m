//
//  HW2CoreDataPostModel.m
//  HW2
//
//  Created by Ian Shafer on 10/25/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "HW2CoreDataPostModel.h"
#import "User.h"

@implementation HW2CoreDataPostModel

+ (HW2CoreDataPostModel *)singletonInstance
{
    static dispatch_once_t pred;
    static HW2CoreDataPostModel *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[HW2CoreDataPostModel alloc] init];
    });
    return sharedInstance;
}

- (User *)createUserWithId:(NSNumber *)userId
                  andEmail:(NSString *)email
              andFirstName:(NSString *)firstName
               andLastName:(NSString *)lastName
                   andName:(NSString *)name
                andImageId:(NSString *)imageId
{
    User *managedUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:_managedObjectContext];
    
    managedUser.userId = userId;
    managedUser.email = email;
    managedUser.name = name;
    managedUser.firstName = firstName;
    managedUser.lastName = lastName;
    managedUser.creationDate = [[NSDate alloc] init];
    managedUser.imageId = imageId;
    
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Could not save new user [%@]", name);
    }
    
    return managedUser;
}

- (User *)findUserByName:(NSString *)name
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"User"
                                                         inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name = %@", name];
    [request setPredicate: predicate];
    
    // TODO Can I create a unique constraint on the core data users table?
    NSError *error;
    NSArray *foundUsers = [_managedObjectContext executeFetchRequest:request error:&error];
    
    if (nil == foundUsers) {
        NSLog(@"User array by name [%@] is nil", name);
        return nil;
    } else {
        if (foundUsers.count == 1) {
            return foundUsers[0];
        } else if (foundUsers.count == 0) {
            return nil;
        } else {
            // TODO
            return nil;
        }
    }
}

- (User *)findUserById:(NSNumber *)userId
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"User" inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"userId = %@", userId];
    [request setPredicate: predicate];
    
    // TODO Can I create a unique constraint on the core data users table?
    NSError *error;
    NSArray *foundUsers = [_managedObjectContext executeFetchRequest:request error:&error];
    
    if (nil == foundUsers) {
        NSLog(@"User array by ID [%@] is nil", userId);
        return nil;
    } else {
        if (foundUsers.count == 1) {
            return foundUsers[0];
        } else if (foundUsers.count == 0) {
            return nil;
        } else {
            // TODO
            return nil;
        }
    }
}

- (NSArray *)findAllUsers
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    return [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (Post *)createPostWithId:(NSNumber *)postId
                   andUser:(User *)user
                  andTitle:(NSString *)title
                   andBody:(NSString *)body
                andImageId:(NSString *)imageId
           andCreationDate:(NSDate *)creationDate
{
    Post *managedPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post"
                                                      inManagedObjectContext:_managedObjectContext];
    
    managedPost.postId = postId;
    managedPost.user = user;
    managedPost.userId = user.userId;
    managedPost.title = title;
    managedPost.body = body;
    managedPost.imageId = imageId;
    managedPost.creationDate = creationDate;
    
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Could not save new post: %@", error.description);
    }
    
    return managedPost;
}

- (void)deletePost:(Post *)post
{
    [_managedObjectContext deleteObject:post];
    
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Could not delete post: %@", error.description);
    }
}

- (void)updatePost:(Post *)post
{
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Could not save updated post: %@", error.description);
    }
}

- (Post *)findPostById:(long)postId
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Post" inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"postId = %ld", postId];
    [request setPredicate: predicate];
    
    // TODO Can I create a unique constraint on the core data users table?
    NSError *error;
    NSArray *foundPosts = [_managedObjectContext executeFetchRequest:request error:&error];
    
    if (nil == foundPosts) {
        NSLog(@"Post array by ID [%ld] is nil", postId);
        return nil;
    } else {
        if (foundPosts.count == 1) {
            return foundPosts[0];
        } else if (foundPosts.count == 0) {
            return nil;
        } else {
            // TODO
            NSLog(@"Found multiple [%d] posts for ID [%ld]", foundPosts.count, postId);
            return nil;
        }
    }
}

- (NSArray *)findAllPosts
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    [fetchRequest setSortDescriptors:@[sort]];
    
    NSError *error;
    return [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (NSFetchedResultsController *)findAllPostsInFetchedResultsController
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]]];
    [fetchRequest setFetchBatchSize:20];

    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error;
    BOOL isSuccess = [controller performFetch:&error];
    if (!isSuccess) {
        [NSException raise:@"Error peforming post fetch" format:@"%@", error.description];
    }
    
    return controller;
}

- (NSArray *)findAllPostsWithOffset:(NSInteger *)offset andLimit:(NSInteger *)limit
{
    return nil;
}

@end
