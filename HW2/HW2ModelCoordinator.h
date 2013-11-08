//
//  HW2ModelCoordinator.h
//  HW2
//
//  Created by Ian Shafer on 11/4/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HW2PostModel.h"

@interface HW2ModelCoordinator : NSObject

+ (HW2ModelCoordinator *)singletonInstance;

- (NSFetchedResultsController *)findAllPostsInFetchedResultsController;

- (void)createPostWithTitle:(NSString *)title
                    andBody:(NSString *)body
                   andImage:(UIImage *)image
                  onSuccess:(void (^)(Post *post))successHandler;

- (void)updatePost:(Post *)post withImage:(UIImage *)image;

- (void)deletePost:(Post *)post;

- (void)getSquareUserImageForUser:(NSNumber *)userId
                        withWidth:(NSNumber *)width
                        onSuccess:(void (^)(UIImage *image))successHandler;

- (void)getSquareImageById:(NSString *)imageId
                 withWidth:(NSNumber *)width
                 onSuccess:(void (^)(UIImage *image))successHandler;

@end
