//
//  GMCoreDataManager.h
//  YelpPhotos
//
//  Created by Gina Mullins on 3/5/16.
//  Copyright © 2016 Gina Mullins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMCoreDataManager : NSObject

+ (GMCoreDataManager *)sharedManager;
- (BOOL)saveSearchResults:(NSArray*)searchResults forTerm:(NSString*)searchTerm;
- (NSArray*)fetchSearchResultsForTerm:(NSString*)searchTerm;

@end
