//
//  HW2PostTableViewCell.m
//  HW2
//
//  Created by Ian Shafer on 10/23/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import "HW2PostTableViewCell.h"
#import "UIColor+Extra.h"

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
    [dateFormatter setDateFormat:@"MMM d, yyyy"];
    _post = post;
    self.textLabel.text = post.title;
    self.detailTextLabel.text = [dateFormatter stringFromDate:post.creationDate];
}

@end
