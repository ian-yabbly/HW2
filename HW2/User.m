//
//  User.m
//  HW2
//
//  Created by Ian Shafer on 10/23/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import "User.h"
#import "Post.h"


@implementation User

@dynamic creationDate;
@dynamic email;
@dynamic firstName;
@dynamic lastName;
@dynamic username;
@dynamic post;

/*
+ (User *)initWithEmail:(NSString *)email andFirstName:(NSString *)firstName andLastName:(NSString *)lastName andUsername:(NSString *)username
{
    User *user = [[User alloc] init];
    
    user.email = email;
    user.firstName = firstName;
    user.lastName = lastName;
    user.username = username;
    user.creationDate = [[NSDate alloc] init];
    
    return user;
}
*/

@end
