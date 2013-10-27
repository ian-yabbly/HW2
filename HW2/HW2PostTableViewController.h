//
//  HW2PostTableViewController.h
//  HW2
//
//  Created by Ian Shafer on 10/23/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

#import "User.h"
#import "HW2PostUpdateDelegate.h"

@interface HW2PostTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, HW2PostUpdateDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) User *author;
@property (nonatomic) NSArray *posts;

@end
