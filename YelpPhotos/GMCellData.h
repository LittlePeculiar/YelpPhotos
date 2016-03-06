//
//  GMCellData.h
//  YelpPhotos
//
//  Created by Gina Mullins on 3/4/16.
//  Copyright © 2016 Gina Mullins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMSearchResultInfo.h"

@interface GMCellData : NSObject

@property (nonatomic, strong) GMSearchResultInfo *info1;
@property (nonatomic, strong) GMSearchResultInfo *info2;
@property (nonatomic, strong) GMSearchResultInfo *info3;

- (instancetype)initWithInfo:(GMSearchResultInfo*)info1
                       info2:(GMSearchResultInfo*)info2
                       info3:(GMSearchResultInfo*)info3;

@end
