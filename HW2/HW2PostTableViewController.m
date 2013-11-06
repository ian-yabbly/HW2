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
#import "HW2ModelCoordinator.h"
#import "UIColor+Extra.h"
#import "Post.h"
#import "User.h"

#define DEFAULT_USERNAME @"ian"

@interface HW2PostTableViewController ()

@end

@implementation HW2PostTableViewController

- (id)init
{
    id v = [super init];
    [self setup];
    return v;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    id v = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self setup];
    return v;
}

- (void)setup
{
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    id v = [super initWithCoder:aDecoder];
    [self setup];
    return v;
}

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
    NSInteger sectionCount = [[_fetchedResultsController sections] count];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    HW2PostTableViewCell *cell = (HW2PostTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Post *post = [_fetchedResultsController objectAtIndexPath:indexPath];
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
        [[HW2ModelCoordinator singletonInstance] deletePost:[_fetchedResultsController objectAtIndexPath:indexPath]];
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
    } else if ([segue.identifier isEqualToString:@"EditPostSegue"]) {
        [dest setPost:sender.post];
        [dest setAuthor:_author];
    } else {
        NSLog(@"Unexpected segue [%@]", segue.identifier);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height) {
        NSLog(@"Reached the end");
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

@end
