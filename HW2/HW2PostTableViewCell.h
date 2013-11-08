//
//  HW2PostTableViewCell.h
//  HW2
//
//  Created by Ian Shafer on 10/23/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Post.h"

@interface HW2PostTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel, *titleLabel;
@property (nonatomic, weak) IBOutlet UITextView *bodyTextView;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;

@property (nonatomic) Post *post;

@end
