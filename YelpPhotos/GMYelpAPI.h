//
//  GMYelpAPI.h
//  YelpPhotos
//
//  Created by Gina Mullins on 3/4/16.
//  Copyright © 2016 Gina Mullins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface GMYelpAPI : NSObject

+ (GMYelpAPI*)sharedManager;
- (void)fetchSearchResultsForTerm:(NSString*)term andLocation:(NSString*)location completionHandler:(void (^)(BOOL isSaved, NSError *error))completionHandler;

@end
