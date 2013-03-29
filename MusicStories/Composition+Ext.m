//
//  Composition+Ext.m
//  MusicStories
//
//  Created by Me Interactive on 28.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "Composition+Ext.h"
#import "Instrument+Ext.h"

@implementation Composition (Ext)
+ (Composition *) syncFromDict:(NSDictionary *)dict
{
    if (!dict || ![dict count])
        return nil;
    Composition *composition = [Composition MR_createEntity];
    composition.name = [dict objectForKey:@"name"];
    NSObject *instruments = [dict objectForKey:@"instruments"];
    if ([instruments isKindOfClass:[NSArray class]])
        for (NSDictionary *inst in (NSArray *)instruments)
        {
            Instrument *instrument = [Instrument syncFromDict:inst];
            if (instrument)
            {
                [composition addListInstumentsObject:instrument];
                [instrument setLinkComposition:composition];
            }
        }
    [Composition save];
    return composition;
}
- (void) deleteWithChilds
{
    for (Instrument *instrument in self.listInstuments)
        [instrument deleteWithChilds];
    [self MR_deleteEntity];
    [Composition save];
}
+ (void) save
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveNestedContexts];
}
@end
