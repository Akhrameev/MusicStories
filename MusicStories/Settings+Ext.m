//
//  Settings+Ext.m
//  MusicStories
//
//  Created by Me Interactive on 28.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "Settings+Ext.h"
#import "CachedData+Ext.h"
#import "VkData+Ext.h"
#import "NSString+Gender.h"

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
+ (BOOL) showIntroduction
{
    return NO;//REDO
    Settings *set = [Settings settings];
    if (!set.lastIntroductionShown)
        return YES;
   
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSDayCalendarUnit
                                                 fromDate: set.lastIntroductionShown toDate: [NSDate date] options: 0];
    NSInteger days = [components day];
    if (days > 50 || days < -50)
        return YES;
    return NO;
}
+ (VkData *) vkDataWithUid:(NSNumber *)uid
{
    return [VkData MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid == %@" argumentArray:@[uid]]];
}
+ (VkData *) vkDataWithDict: (NSDictionary *) dict
{
    NSObject *uid = [dict objectForKey:@"uid"];
    if (![uid isKindOfClass:[NSNumber class]])
        return nil;
    VkData *vkData = [Settings vkDataWithUid:(NSNumber *)uid];
    if (vkData)
        return vkData;
    Settings *set = [Settings settings];
    vkData = [VkData MR_createEntity];
    NSObject *temp = [dict objectForKey:@"bdata"];
    if ([temp isKindOfClass:[NSString class]])
        vkData.bdate = (NSString *)temp;
    temp = [dict objectForKey:@"first_name"];
    if ([temp isKindOfClass:[NSString class]])
        vkData.firstName = (NSString *)temp;
    temp = [dict objectForKey:@"last_name"];
    if ([temp isKindOfClass:[NSString class]])
        vkData.lastName = (NSString *)temp;
    temp = [dict objectForKey:@"photo"];
    if ([temp isKindOfClass:[NSString class]])
        vkData.photoUrl = (NSString *)temp;
    temp = [dict objectForKey:@"photo_big"];
    if ([temp isKindOfClass:[NSString class]])
        vkData.photoBigUrl = (NSString *)temp;
    temp = [dict objectForKey:@"sex"];
    if ([temp isKindOfClass:[NSNumber class]])
    {
        vkData.sex = (NSNumber *)temp;
        vkData.sexString = [NSString stringWithGenderId:vkData.sex.integerValue];
    }
    temp = [dict objectForKey:@"uid"];
    if ([temp isKindOfClass:[NSNumber class]])
        vkData.uid = (NSNumber *)temp;
    vkData.linkSettings = set;
    [set addListVkDataObject:vkData];
    [Settings save];
    return vkData;
}
@end
