//
//  GMSearchResultInfo.m
//  YelpPhotos
//
//  Created by Gina Mullins on 3/4/16.
//  Copyright © 2016 Gina Mullins. All rights reserved.
//

#import "GMSearchResultInfo.h"

@implementation GMSearchResultInfo

- (instancetype)initWithSearchTerm:(NSString*)searchTerm
                        resultName:(NSString*)resultName
                          resultID:(NSString*)resultID
                    resultImageURL:(NSString*)resultImageURL
{
    if ((self = [super init]))
    {
        self.searchTerm = searchTerm;
        self.resultName = resultName;
        self.resultID = resultID;
        self.resultImageURL = resultImageURL;
    }
    
    return self;
}

@end
