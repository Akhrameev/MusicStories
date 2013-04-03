//
//  VkData+Ext.h
//  MusicStories
//
//  Created by Me Interactive on 01.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "VkData.h"

@interface VkData (Ext)
- (UIImage *) photo;
- (UIImage *) photoBig;
+ (void) save;
@property (strong, nonatomic) NSURLConnection *urlconnection;
@property (strong, nonatomic) NSMutableData *responseData;
@property NSInteger currentRequestType;
@end
