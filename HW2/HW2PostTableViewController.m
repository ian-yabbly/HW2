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
#import "HW2CoreDataPostModel.h"
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
    
    _author = [[HW2CoreDataPostModel singletonInstance] findUserByUsername:DEFAULT_USERNAME];
    if (nil == _author) {
        _author = [[HW2CoreDataPostModel singletonInstance] createUserWithEmail:@"ian@yabbly.com"
                                                                   andFirstName:@"Ian"
                                                                    andLastName:@"Shafer"
                                                                    andUsername:DEFAULT_USERNAME];
    }
    
    // Now retreive all the Posts
    _posts = [self findAllPosts];
    
    if (_posts.count == 0) {
        while (_posts.count < 10) {
            [[HW2CoreDataPostModel singletonInstance] createPostWithAuthor:_author
                                                                  andTitle:[NSString stringWithFormat:@"Title of post #%d", _posts.count]
                                                                   andBody:[NSString stringWithFormat:@"Body of post #%d", _posts.count]];
            
            _posts = [self findAllPosts];
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
    
    Post *post = _posts[indexPath.row];
    [cell setPost:post];
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(HW2PostTableViewCell *)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    HW2PostFormViewController *dest = (HW2PostFormViewController *) [segue destinationViewController];
    if ([segue.identifier isEqualToString:@"NewPostSegue"]) {
        [dest setPost:nil];
        [dest setAuthor:_author];
        [dest setPostUpdateDelegate:self];
    } else if ([segue.identifier isEqualToString:@"EditPostSegue"]) {
        [dest setPost:sender.post];
        [dest setAuthor:_author];
        [dest setPostUpdateDelegate:self];
    } else {
        NSLog(@"Unexpected segue [%@]", segue.identifier);
    }
}

#pragma mark - Model

- (NSArray *)findAllPosts
{
    return [[HW2CoreDataPostModel singletonInstance] findAllPosts];
}

- (void)deletePostAtIndexPath:(NSIndexPath *)indexPath
{
    [[HW2CoreDataPostModel singletonInstance] deletePost:_posts[indexPath.row]];

    // TODO There should be a better way to do this
    _posts = [self findAllPosts];
}

- (void)postWasCreated:(Post *)post
{
    // TODO there may be a better way
    _posts = [self findAllPosts];
    [[self tableView] reloadData];
}

- (void)postWasUpdated:(Post *)post
{
    // TODO there may be a better way
    _posts = [self findAllPosts];
    [[self tableView] reloadData];
}

@end
