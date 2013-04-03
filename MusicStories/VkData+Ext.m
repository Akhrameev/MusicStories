//
//  VkData+Ext.m
//  MusicStories
//
//  Created by Me Interactive on 01.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "VkData+Ext.h"

enum requestType {REQUEST_TYPE_PHOTO, REQUEST_TYPE_PHOTO_BIG};

@implementation VkData (Ext)
@dynamic urlconnection;
@dynamic responseData;
@dynamic currentRequestType;

- (UIImage *) photo
{
    if (!self.photoData)
    {
        self.responseData = [NSMutableData data];
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:self.photoUrl]];
        self.currentRequestType = REQUEST_TYPE_PHOTO;
        self.urlconnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return [UIImage imageWithData:self.photoData];
}
- (UIImage *) photoBig
{
    if (!self.photoBigData)
    {
        self.responseData = [NSMutableData data];
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:self.photoBigUrl]];
        self.currentRequestType = REQUEST_TYPE_PHOTO_BIG;
        self.urlconnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return [UIImage imageWithData:self.photoBigData];
}
+ (void) save
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveNestedContexts];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //clear responseData on response
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //append new data to responseData
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //alert view to show error to user, and stop visualizing refreshing on error
    self.responseData = nil;
    self.urlconnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection != self.urlconnection)
        return;
    if (self.currentRequestType == REQUEST_TYPE_PHOTO)
        self.photoData = self.responseData;
    else if (self.currentRequestType == REQUEST_TYPE_PHOTO_BIG)
        self.photoBigData = self.responseData;
    self.responseData = nil;
    self.urlconnection = nil;
    [VkData save];
}


@end
