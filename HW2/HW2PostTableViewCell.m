//
//  HW2PostTableViewCell.m
//  HW2
//
//  Created by Ian Shafer on 10/23/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import "HW2PostTableViewCell.h"
#import "HW2ModelCoordinator.h"
#import "User.h"
#import "Post.h"

@implementation HW2PostTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// TODO Not sure if this is how I should set the cell's content. It feels wrong here.
- (void)setPost:(Post *)post
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, yyyy HH:mm"];
    _post = post;
    
    self.titleLabel.text = post.title;
    self.bodyTextView.text = post.body;
    self.nameLabel.text = post.user.name;
    
    NSNumber *userImageWidth = [NSNumber numberWithInt:_userImageView.frame.size.width];
    
    [[HW2ModelCoordinator singletonInstance] getSquareUserImageForUser:self.post.user.userId
                                                             withWidth:userImageWidth
                                                             onSuccess:^(UIImage *image) {
                                                                 _userImageView.image = image;
                                                             }];
}

@end
