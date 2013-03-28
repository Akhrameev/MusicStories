//
//  Settings+Ext.m
//  MusicStories
//
//  Created by Me Interactive on 28.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "Settings+Ext.h"

@implementation Settings (Ext)
+ (Settings *) settings
{
    Settings * settings = [Settings MR_findFirst];
    if (!settings)
    {
        settings = [Settings MR_createEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveNestedContexts];
    }
    return settings;
}
@end
