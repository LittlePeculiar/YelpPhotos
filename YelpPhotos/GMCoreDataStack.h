//
//  GMCoreDataStack.h
//  YelpPhotos
//
//  Created by Gina Mullins on 3/5/16.
//  Copyright © 2016 Gina Mullins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GMCoreDataStack : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *privateManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (GMCoreDataStack *)sharedManager;
- (BOOL)saveContext;

@end
