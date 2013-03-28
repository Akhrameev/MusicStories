//
//  Compositor+Ext.m
//  MusicStories
//
//  Created by Me Interactive on 28.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "Compositor+Ext.h"
#import "Composition+Ext.h"

@implementation Compositor (Ext)
+ (Compositor *) syncFromDict:(NSDictionary *)dict
{
    if (!dict || ![dict count])
        return nil;
    Compositor *compositor = [Compositor MR_createEntity];
    compositor.name = [dict objectForKey:@"name"];
    NSObject *compositions = [dict objectForKey:@"compositions"];
    if ([compositions isKindOfClass:[NSArray class]])
        for (NSDictionary *comp in (NSArray *)compositions)
        {
            Composition *composition = [Composition syncFromDict:comp];
            if (composition)
            {
                [compositor addListCompositionsObject:composition];
                composition.linkCompositor = compositor;
            }
        }
    [[NSManagedObjectContext MR_defaultContext] MR_saveNestedContexts];
    return compositor;
}
- (void) deleteWithChilds
{
    for (Composition *composition in self.listCompositions)
         [composition deleteWithChilds];
    [self MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveNestedContexts];
}
@end
