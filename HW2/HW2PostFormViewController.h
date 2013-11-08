//
//  HW2PostFormViewController.h
//  HW2
//
//  Created by Ian Shafer on 10/24/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Post.h"
#import "User.h"

@interface HW2PostFormViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UITextField *fieldTitle;
@property (nonatomic, weak) IBOutlet UITextView *fieldBody;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic) User *author;
@property (nonatomic) Post *post;
@property (nonatomic) BOOL newImageSelected;

- (IBAction)saveTapped:(id)sender;

@end
