//
//  GMCoreDataManager.m
//  YelpPhotos
//
//  Created by Gina Mullins on 3/5/16.
//  Copyright © 2016 Gina Mullins. All rights reserved.
//

#import "GMCoreDataManager.h"
#import <CoreData/CoreData.h>
#import "GMCoreDataStack.h"
#import "GMSearchResultInfo.h"
#import "GMCellData.h"


@implementation GMCoreDataManager

+ (GMCoreDataManager *)sharedManager
{
    static GMCoreDataManager *myManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myManager = [[self alloc] init];
    });
    
    return myManager;
}

- (BOOL)saveSearchResults:(NSArray*)searchResults forTerm:(NSString*)searchTerm
{
    if (searchResults.count == 0) {
        return NO;
    }
    
    __block BOOL isSaved = YES;     // all should be well
    
    // delete current search results
    [self deleteSearchResultsForTerm:searchTerm];
    
    __block NSManagedObjectContext *context = [GMCoreDataStack sharedManager].managedObjectContext;
    __block NSManagedObjectContext *privateContext = [GMCoreDataStack sharedManager].privateManagedObjectContext;
    __block NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = context;
    
    [temporaryContext performBlockAndWait:^{
        
        int counter = 1;
        NSLog(@"saving %@ searchResults", @(searchResults.count));
        for (GMSearchResultInfo *info in searchResults) {
            NSManagedObject	*obj = [NSEntityDescription insertNewObjectForEntityForName:@"SearchResultEntity" inManagedObjectContext:context];
            [obj setValue:info.searchTerm forKey:@"searchTerm"];
            [obj setValue:info.resultID forKey:@"resultID"];
            [obj setValue:info.resultName forKey:@"resultName"];
            [obj setValue:info.resultImageURL forKey:@"resultImageURL"];
            
            // save every 100 records
            if (counter % 100 == 0)
            {
                // Save the context.
                NSError *error = nil;
                if (![temporaryContext save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                }
            }
            counter++;
        }
        
        // Save the context.
        NSError *error = nil;
        if (![temporaryContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            isSaved = NO;
        }
        
        [context performBlockAndWait:^{
            // Save the context.
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                isSaved = NO;
            }
            
            [privateContext performBlockAndWait:^{
                // Save the context.
                NSError *error = nil;
                if (![privateContext save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    isSaved = NO;
                }
                
            }];
        }];
    }];
    
    return isSaved;
}

- (NSArray*)fetchSearchResultsForTerm:(NSString*)searchTerm
{
    NSMutableArray *searchResults = [[NSMutableArray alloc] init];
    
    __block NSManagedObjectContext *context = [GMCoreDataStack sharedManager].managedObjectContext;
    
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SearchResultEntity"];
        
        // setup predicate
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"(searchTerm == %@)", searchTerm];
        NSArray *subPredicates = @[pred1];
        NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        [fetchRequest setPredicate:predicates];
        
        // Set sort orderings...
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"resultName" ascending:YES];
        [fetchRequest setSortDescriptors:@[nameDescriptor]];
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        for (NSManagedObject *obj in fetchedObjects)
        {
            GMSearchResultInfo *result = [[GMSearchResultInfo alloc]
                                          initWithSearchTerm:searchTerm
                                          resultName:(NSString*)[obj valueForKey:@"resultName"]
                                          resultID:(NSString*)[obj valueForKey:@"resultID"]
                                          resultImageURL:(NSString*)[obj valueForKey:@"resultImageURL"]];

            
            [searchResults addObject:result];
        }
    }];
    
    // need to setup results for displaying in cells...in sets of three
    // cant wait to see alternative solutions
    NSMutableArray *results = [[NSMutableArray alloc] init];
    GMCellData *data = nil;
    for (GMSearchResultInfo *info in searchResults) {
        if (data == nil) {
            // setup with first entry
            data = [[GMCellData alloc] initWithInfo:info info2:nil info3:nil];
        }
        else {
            if (data.info2 == nil) {
                data.info2 = info;
            }
            else if (data.info3 == nil) {
                data.info3 = info;
                [results addObject:data];
                data = nil;
            }
        }
    }
    
    // add the last one, which could be less than three
    // again, cant wait to see another way
    if (![results containsObject:data]) {
        if (data != nil) {
            [results addObject:data];
        }
    }
    
    return results;
}

- (BOOL)deleteSearchResultsForTerm:(NSString*)searchTerm
{
    __block NSManagedObjectContext *context = [GMCoreDataStack sharedManager].managedObjectContext;
    __block NSManagedObjectContext *privateContext = [GMCoreDataStack sharedManager].privateManagedObjectContext;
    __block NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = context;
    
    __block BOOL isSaved = YES;     // all should be well
    
    [temporaryContext performBlockAndWait:^{
        
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SearchResultEntity"];
        
        // setup predicate
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"(searchTerm == %@)", searchTerm];
        NSArray *subPredicates = @[pred1];
        NSPredicate *predicates = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        [fetchRequest setPredicate:predicates];
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        NSLog(@"deleting %@ searchResults", @(fetchedObjects.count));
        
        for (NSManagedObject *info in fetchedObjects)
        {
            [context deleteObject:info];
        }
        
        // Save the context.
        if (![temporaryContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            isSaved = NO;
        }
        
        [context performBlockAndWait:^{
            // Save the context.
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                isSaved = NO;
            }
            
            [privateContext performBlockAndWait:^{
                // Save the context.
                NSError *error = nil;
                if (![privateContext save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    isSaved = NO;
                }
                
            }];
        }];
        
    }];
    
    // Save the context.
    return isSaved;
}

@end
