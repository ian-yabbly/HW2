//
//  HW2PostFormViewController.h
//  HW2
//
//  Created by Ian Shafer on 10/24/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HW2PostUpdateDelegate.h"
#import "Post.h"
#import "User.h"

@interface HW2PostFormViewController : UIViewController

@property (nonatomic) IBOutlet UITextField *fieldTitle;

@property (nonatomic) IBOutlet UITextView *fieldBody;

@property (nonatomic) User *author;

@property (nonatomic) Post *post;

@property (nonatomic) id<HW2PostUpdateDelegate> postUpdateDelegate;

- (IBAction)saveTapped:(id)sender;

@end
