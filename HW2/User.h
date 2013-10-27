//
//  User.h
//  HW2
//
//  Created by Ian Shafer on 10/23/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface User : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSOrderedSet *post;
@end

@interface User (CoreDataGeneratedAccessors)

//+ (User *)initWithEmail:(NSString *)email andFirstName:(NSString *)firstName andLastName:(NSString *)lastName andUsername:(NSString *)username;

- (void)insertObject:(Post *)value inPostAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPostAtIndex:(NSUInteger)idx;
- (void)insertPost:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePostAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPostAtIndex:(NSUInteger)idx withObject:(Post *)value;
- (void)replacePostAtIndexes:(NSIndexSet *)indexes withPost:(NSArray *)values;
- (void)addPostObject:(Post *)value;
- (void)removePostObject:(Post *)value;
- (void)addPost:(NSOrderedSet *)values;
- (void)removePost:(NSOrderedSet *)values;

@end