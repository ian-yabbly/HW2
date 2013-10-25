//
//  HW2PostFormViewController.m
//  HW2
//
//  Created by Ian Shafer on 10/24/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import "HW2PostFormViewController.h"

@interface HW2PostFormViewController ()

@end

@implementation HW2PostFormViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelTapped:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveTapped:(id)sender
{
    [_postModel addPostWithAuthor:_author title:_fieldTitle.text body:_fieldBody.text];
}
@end
