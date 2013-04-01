//
//  VkData+Ext.m
//  MusicStories
//
//  Created by Me Interactive on 01.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "VkData+Ext.h"

@implementation VkData (Ext)
- (UIImage *) photo
{
    if (!self.photoData)
    {
        self.photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.photoUrl]];
        [VkData save];
    }
    return [UIImage imageWithData:self.photoData];
}
- (UIImage *) photoBig
{
    if (!self.photoBigData)
    {
        self.photoBigData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.photoBigUrl]];
        [VkData save];
    }
    return [UIImage imageWithData:self.photoBigData];
}
+ (void) save
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveNestedContexts];
}
@end
