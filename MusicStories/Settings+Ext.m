//
//  Settings+Ext.m
//  MusicStories
//
//  Created by Me Interactive on 28.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "Settings+Ext.h"
#import "CachedData+Ext.h"

@implementation Settings (Ext)
+ (Settings *) settings
{
    Settings * settings = [Settings MR_findFirst];
    if (!settings)
    {
        settings = [Settings MR_createEntity];
        [Settings save];
    }
    return settings;
}
+ (void) save
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveNestedContexts];
}
+ (NSData *) dataFromCacheForURL: (NSString *) url
{
    Settings *set = [Settings settings];
    for (CachedData *cache in set.listCachedData)
        if ([cache.url isEqualToString:url])
            return cache.data;
    return nil;
}
+ (void) saveDataInCacheFromURL:(NSString *)url : (NSData *) data
{
    CachedData *cacheData;
    Settings *set = [Settings settings];
    for (CachedData *cache in set.listCachedData)
        if ([cache.url isEqualToString:url])
        {
            cacheData = cache;
            break;
        }
    if (cacheData == nil)
    {
        cacheData = [CachedData MR_createEntity];
        cacheData.url = url;
        cacheData.linkSettings = set;
        [set addListCachedDataObject:cacheData];
    }
    cacheData.data = data;
    [Settings save];
}
+ (void) clearDataFromCacheForURL: (NSString *) url
{
    Settings *set = [Settings settings];
    for (CachedData *cache in set.listCachedData)
        if ([cache.url isEqualToString:url])
        {
            [set removeListCachedDataObject:cache];
            [cache deleteEntity];
            [Settings save];
            return;
        }
}
+ (void) clearCache
{
    Settings *set = [Settings settings];
    CachedData *cache = nil;
    while ((cache = [set.listCachedData anyObject]) != nil)
    {
        [set removeListCachedDataObject:cache];
        [cache deleteEntity];
    }
    [Settings save];
}
@end
