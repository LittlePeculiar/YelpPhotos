//
//  NSURLRequest+OAuth.m
//  YelpAPISample
//
//  Created by Thibaud Robelain on 7/2/14.
//  Copyright (c) 2014 Yelp Inc. All rights reserved.
//

#import "NSURLRequest+OAuth.h"

#import <TDOAuth/TDOAuth.h>

/**
 OAuth credential placeholders that must be filled by each user in regards to
 http://www.yelp.com/developers/getting_started/api_access
 */
//#warning Fill in the API keys below with your developer v2 keys.
static NSString * const kConsumerKey       = @"ypFnMQ9m8fJH13URynuGTQ";
static NSString * const kConsumerSecret    = @"OfonjPUUZwFLzwavD1SAAnMFld8";
static NSString * const kToken             = @"ih9VtD-D0E-Ij3yiC6-TQlDTnvv6x-Z6";
static NSString * const kTokenSecret       = @"CnJFDYNpvdu_yvF8exqWzsv4Z5s";

@implementation NSURLRequest (OAuth)

+ (NSURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path {
  return [self requestWithHost:host path:path params:nil];
}

+ (NSURLRequest *)requestWithHost:(NSString *)host path:(NSString *)path params:(NSDictionary *)params {
  if ([kConsumerKey length] == 0 || [kConsumerSecret length] == 0 || [kToken length] == 0 || [kTokenSecret length] == 0) {
    NSLog(@"WARNING: Please enter your api v2 credentials before attempting any API request. You can do so in NSURLRequest+OAuth.m");
  }

  return [TDOAuth URLRequestForPath:path
                      GETParameters:params
                             scheme:@"https"
                               host:host
                        consumerKey:kConsumerKey
                     consumerSecret:kConsumerSecret
                        accessToken:kToken
                        tokenSecret:kTokenSecret];
}

@end
