//
//  Instrument+Ext.m
//  MusicStories
//
//  Created by Me Interactive on 28.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "Instrument+Ext.h"

@implementation Instrument (Ext)
+ (Instrument *) syncFromDict: (NSDictionary *) dict
{
    if (!dict || ![dict count])
        return nil;
    Instrument *instrument = [Instrument MR_createEntity];
    instrument.url = [dict objectForKey:@"url"];
    instrument.name = [dict objectForKey:@"name"];
    instrument.pic = [dict objectForKey:@"pic"];
    instrument.id = [dict objectForKey:@"id"];
    [[NSManagedObjectContext MR_defaultContext] MR_saveNestedContexts];
    return instrument;
}
- (void) deleteWithChilds
{
    [self MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveNestedContexts];
}
@end
