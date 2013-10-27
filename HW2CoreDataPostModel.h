//
//  HW2CoreDataPostModel.h
//  HW2
//
//  Created by Ian Shafer on 10/25/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HW2PostModel.h"

@interface HW2CoreDataPostModel : NSObject <HW2PostModel>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (HW2CoreDataPostModel *)singletonInstance;

@end
