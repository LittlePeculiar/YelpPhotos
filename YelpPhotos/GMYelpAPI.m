//
//  GMYelpAPI.m
//  YelpPhotos
//
//  Created by Gina Mullins on 3/4/16.
//  Copyright © 2016 Gina Mullins. All rights reserved.
//

#import "GMYelpAPI.h"
#import "NSURLRequest+OAuth.h"
#import "GMSearchResultInfo.h"
#import "GMCoreDataManager.h"


static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search/";


@implementation GMYelpAPI


+ (GMYelpAPI*)sharedManager
{
    static GMYelpAPI *myManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myManager = [[self alloc] init];
    });
    
    return myManager;
}

- (void)fetchSearchResultsForTerm:(NSString*)term andLocation:(NSString*)location completionHandler:(void (^)(BOOL isSaved, NSError *error))completionHandler
{
    NSLog(@"Querying the Search API with term \'%@\' and location \'%@'", term, location);
    
    //Make a first request to get the search results with the passed term and location
    NSURLRequest *searchRequest = [self _searchRequestWithTerm:term location:location];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:searchRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (!error && httpResponse.statusCode == 200) {
            
            NSDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSArray *businessArray = searchResponseJSON[@"businesses"];
            
            NSMutableArray *searchResults = [NSMutableArray new];
            for (NSDictionary *business in businessArray) {
                GMSearchResultInfo *info = [[GMSearchResultInfo alloc]
                                            initWithSearchTerm:term
                                            resultName:(NSString*)[self nullToString:[business objectForKey:@"name"]]
                                            resultID:(NSString*)[self nullToString:[business objectForKey:@"id"]]
                                            resultImageURL:(NSString*)[self nullToString:[business objectForKey:@"image_url"]]];
                [searchResults addObject:info];
            }
            
            if (searchResults.count > 0) {
                BOOL isSaved = [[GMCoreDataManager sharedManager] saveSearchResults:searchResults forTerm:term];
                completionHandler(isSaved, error);
            }else {
                completionHandler(NO, error); // An error happened or the HTTP response is not a 200 OK
            }
            
        } else {
            completionHandler(NO, error); // An error happened or the HTTP response is not a 200 OK
        }
    }] resume];
}

// https://github.com/Yelp/yelp-api/tree/master/v2/objective-c
// remove search limit
- (NSURLRequest *)_searchRequestWithTerm:(NSString *)term location:(NSString *)location {
    NSDictionary *params = @{
                             @"term": term,
                             @"location": location
                             };
    
    return [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params];
}

- (NSString*)nullToString:(id)object {
    NSString *string = @"";
    
    if (object != [NSNull null] || object != nil) {
        string = object;
    }
    
    return string;
}


@end
