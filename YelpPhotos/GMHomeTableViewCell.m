//
//  GMHomeTableViewCell.m
//  YelpPhotos
//
//  Created by Gina Mullins on 3/4/16.
//  Copyright © 2016 Gina Mullins. All rights reserved.
//

#import "GMHomeTableViewCell.h"
#import "UIImageView+AFNetworking.h"


@implementation GMHomeTableViewCell

- (void)awakeFromNib {
   
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setData:(GMCellData *)data
{
    if (data != nil) {
        if (data.info1 != nil) {
            
            NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:data.info1.resultImageURL]
                                                          cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                      timeoutInterval:60];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageView1 setImageWithURLRequest:imageRequest
                                       placeholderImage:[UIImage imageNamed:@"placeholder"]
                                                success:nil
                                                failure:nil];
            });
        }
        else {
            self.imageView1.image = [UIImage imageNamed:@"placeholder"];
        }
        if (data.info2 != nil) {
            
            NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:data.info2.resultImageURL]
                                                          cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                      timeoutInterval:60];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageView2 setImageWithURLRequest:imageRequest
                                       placeholderImage:[UIImage imageNamed:@"placeholder"]
                                                success:nil
                                                failure:nil];
            });
        }
        else {
            self.imageView2.image = [UIImage imageNamed:@"placeholder"];
        }
        if (data.info3 != nil) {
            
            NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:data.info3.resultImageURL]
                                                          cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                      timeoutInterval:60];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageView3 setImageWithURLRequest:imageRequest
                                       placeholderImage:[UIImage imageNamed:@"placeholder"]
                                                success:nil
                                                failure:nil];
            });
        }
        else {
            self.imageView3.image = [UIImage imageNamed:@"placeholder"];
        }
    }
}


@end
