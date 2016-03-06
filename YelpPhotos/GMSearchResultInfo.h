//
//  GMSearchResultInfo.h
//  YelpPhotos
//
//  Created by Gina Mullins on 3/4/16.
//  Copyright © 2016 Gina Mullins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMSearchResultInfo : NSObject

@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, strong) NSString *resultName;
@property (nonatomic, strong) NSString *resultID;
@property (nonatomic, strong) NSString *resultImageURL;


- (instancetype)initWithSearchTerm:(NSString*)searchTerm
                        resultName:(NSString*)resultName
                          resultID:(NSString*)resultID
                    resultImageURL:(NSString*)resultImageURL;
@end
