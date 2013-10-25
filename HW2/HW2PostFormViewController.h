//
//  HW2PostFormViewController.h
//  HW2
//
//  Created by Ian Shafer on 10/24/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HW2PostTableViewController.h"

@interface HW2PostFormViewController : UIViewController

@property (nonatomic) IBOutlet UITextField *fieldTitle;

@property (nonatomic) IBOutlet UITextView *fieldBody;

@property (nonatomic) User *author;

@property (nonatomic) HW2PostTableViewController *postModel;

- (IBAction)cancelTapped:(id)sender;

- (IBAction)saveTapped:(id)sender;

@end
