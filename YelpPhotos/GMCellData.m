//
//  GMCellData.m
//  YelpPhotos
//
//  Created by Gina Mullins on 3/4/16.
//  Copyright © 2016 Gina Mullins. All rights reserved.
//

#import "GMCellData.h"

@implementation GMCellData


- (instancetype)initWithInfo:(GMSearchResultInfo*)info1
                       info2:(GMSearchResultInfo*)info2
                       info3:(GMSearchResultInfo*)info3
{
    if ((self = [super init]))
    {
        self.info1 = info1;
        self.info2 = info2;
        self.info3 = info3;
    }
    
    return self;
}

@end
