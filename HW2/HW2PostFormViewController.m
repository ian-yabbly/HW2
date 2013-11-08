//
//  HW2PostFormViewController.m
//  HW2
//
//  Created by Ian Shafer on 10/24/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import "HW2PostFormViewController.h"
#import "HW2ModelCoordinator.h"

@interface HW2PostFormViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

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
        
        if (_post.imageId) {
            NSNumber *imageWidth = [NSNumber numberWithInt:_imageView.frame.size.width];
            [[HW2ModelCoordinator singletonInstance] getSquareImageById:_post.imageId
                                                              withWidth:imageWidth
                                                              onSuccess:^(UIImage *image) {
                                                                  _imageView.image = image;
                                                              }];
        }
        
        [self setTitle:@"Edit Post"];
    } else {
        _fieldTitle.text = nil;
        _fieldBody.text = nil;
        [self setTitle:@"New Post"];
    }
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleImageTap:)];
    [_imageView addGestureRecognizer:recognizer];
    _newImageSelected = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveTapped:(id)sender
{
    UIImage *newImage = nil;
    if (_newImageSelected) {
        newImage = _imageView.image;
    }
    
    if (_post) {
        _post.title = _fieldTitle.text;
        _post.body = _fieldBody.text;
        [[HW2ModelCoordinator singletonInstance] updatePost:_post withImage:newImage];
    } else {
        [[HW2ModelCoordinator singletonInstance] createPostWithTitle:_fieldTitle.text
                                                             andBody:_fieldBody.text
                                                            andImage:newImage
                                                           onSuccess:nil];
    }
    
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)handleImageTap:(UITapGestureRecognizer *)recognizer
{
    UIActionSheet *actionSheet = nil;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From Camera Roll", @"Take a Photo", nil];

    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"From Camera Roll", nil];

    }
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex == buttonIndex) { return; }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate:self];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (buttonIndex == 0) {
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        } else if (buttonIndex == 1) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            NSLog(@"Unexpected button index [%d]", buttonIndex);
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    } else {
        if (buttonIndex == 0) {
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        } else {
            NSLog(@"Unexpected button index [%d]", buttonIndex);
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    
    [picker setAllowsEditing:YES];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *pickedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        CGSize croppedSize = CGSizeMake(200, 200);
        UIImage *croppedSquareImage = [self squareImageWithImage:pickedImage scaledToSize:croppedSize];
        _imageView.image = croppedSquareImage;
        _newImageSelected = YES;
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
