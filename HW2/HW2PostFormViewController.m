//
//  HW2PostFormViewController.m
//  HW2
//
//  Created by Ian Shafer on 10/24/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import "HW2PostFormViewController.h"
#import "HW2CoreDataPostModel.h"

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
    
    if (_post) {
        _fieldTitle.text = _post.title;
        _fieldBody.text = _post.body;
        [self setTitle:@"Edit Post"];
    } else {
        _fieldTitle.text = nil;
        _fieldBody.text = nil;
        [self setTitle:@"New Post"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveTapped:(id)sender
{
    if (_post) {
        _post.title = _fieldTitle.text;
        _post.body = _fieldBody.text;
        [[HW2CoreDataPostModel singletonInstance] updatePost:_post];
        [_postUpdateDelegate postWasCreated:_post];
    } else {
        Post *createdPost = [[HW2CoreDataPostModel singletonInstance] createPostWithAuthor:_author
                                                              andTitle:_fieldTitle.text
                                                               andBody:_fieldBody.text];
        [_postUpdateDelegate postWasCreated:createdPost];
    }
    
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
