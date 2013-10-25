//
//  HW2PostTableViewController.m
//  HW2
//
//  Created by Ian Shafer on 10/23/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import "HW2PostTableViewCell.h"
#import "HW2PostTableViewController.h"
#import "HW2PostFormViewController.h"
#import "Post.h"
#import "User.h"

#define DEFAULT_USERNAME @"ian"

@interface HW2PostTableViewController ()

@end

@implementation HW2PostTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // First look for a User with username of DEFAULT_USERNAME. If this does not exist
    // create it. This will be the default User.
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"User" inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(username = '%@')", DEFAULT_USERNAME];
    [request setPredicate: predicate];
    
    NSError *error;
    NSArray *userArray = [_managedObjectContext executeFetchRequest:request error:&error];

    if (nil != userArray) {
        NSUInteger count = [userArray count];
        if (1 == count) {
            _author = userArray[0];
        } else if (0 == count) {
            // Create the default user
            User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:_managedObjectContext];
            user.username = DEFAULT_USERNAME;
            user.firstName = @"Ian";
            user.lastName = @"Shafer";
            user.creationDate = [[NSDate alloc] init];
            if (![_managedObjectContext save:&error]) {
                NSLog(@"Could not save new user [%@]", DEFAULT_USERNAME);
            }
            _author = user;
        } else {
            NSLog(@"Unexpected numer of results for User with username [%@]", DEFAULT_USERNAME);
        }
    } else {
        // Not sure how to handle error
        NSLog(@"We had a problem getting the user %@", DEFAULT_USERNAME);
    }
    
    // Now retreive all the Posts
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    _posts = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Found [%d] posts", [_posts count]);
    
    if (_posts.count == 0) {
        while (_posts.count < 10) {
            NSLog(@"Creating post");
            [self addPostWithAuthor:_author title:[NSString stringWithFormat:@"Title of post #%d", _posts.count] body:[NSString stringWithFormat:@"Body of post #%d", _posts.count]];
        }
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    HW2PostTableViewCell *cell = (HW2PostTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSLog(@"Cell [%@]", cell);
    Post *post = _posts[indexPath.row];
    [cell setPost:post];
    //cell.textLabel.text = post.title;
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self deletePostAtIndexPath:indexPath];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    HW2PostFormViewController *dest = (HW2PostFormViewController *) [segue destinationViewController];
    //dest.postModel = self;
    //dest.author = _author;
}

#pragma mark - Model

- (void)findAllPosts
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    _posts = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Found [%d] posts", [_posts count]);
}

- (void)addPostWithAuthor:(User *)author title:(NSString *)title body:(NSString *)body
{
    Post *post = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:_managedObjectContext];
    post.author = author;
    post.title = title;
    post.body = body;
    post.creationDate = [[NSDate alloc] init];
    
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Could not save new post: %@", error.description);
    }
    
    [self findAllPosts];
}

- (void)deletePostAtIndexPath:(NSIndexPath *)indexPath
{
    [_managedObjectContext deleteObject:_posts[indexPath.row]];

    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Could not delete post: %@", error.description);
    }

    [self findAllPosts];
}

@end
