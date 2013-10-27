//
//  HW2CoreDataPostModel.m
//  HW2
//
//  Created by Ian Shafer on 10/25/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "HW2CoreDataPostModel.h"

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

- (User *)createUserWithEmail:(NSString *)email
                 andFirstName:(NSString *)firstName
                  andLastName:(NSString *)lastName
                  andUsername:(NSString *)username;
{
    User *managedUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:_managedObjectContext];
    
    managedUser.email = email;
    managedUser.username = username;
    managedUser.firstName = firstName;
    managedUser.lastName = lastName;
    managedUser.creationDate = [[NSDate alloc] init];
    
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Could not save new user [%@]", username);
    }
    
    return managedUser;
}

- (User *)findUserByUsername:(NSString *)username
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"User" inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"username = %@", username];
    [request setPredicate: predicate];
    
    // TODO Can I create a unique constraint on the core data users table?
    NSError *error;
    NSArray *foundUsers = [_managedObjectContext executeFetchRequest:request error:&error];
    
    if (nil == foundUsers) {
        NSLog(@"User array by username [%@] is nil", username);
        return nil;
    } else {
        if (foundUsers.count == 1)
        {
            return foundUsers[0];
        }
        else if (foundUsers.count == 0)
        {
            return nil;
        }
        else
        {
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

- (Post *)createPostWithAuthor:(User *)author andTitle:(NSString *)title andBody:(NSString *)body;
{
    Post *managedPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:_managedObjectContext];
    managedPost.author = author;
    managedPost.title = title;
    managedPost.body = body;
    managedPost.creationDate = [[NSDate alloc] init];
    
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

- (NSArray *)findAllPosts
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    return [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (NSArray *)findAllPostsWithOffset:(NSInteger *)offset andLimit:(NSInteger *)limit
{
    return nil;
}

@end
