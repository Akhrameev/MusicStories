//
//  Compositor+Ext.h
//  MusicStories
//
//  Created by Me Interactive on 28.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "Compositor.h"

@interface Compositor (Ext)
+ (Compositor *) syncFromDict:(NSDictionary *)dict;
- (void) deleteWithChilds;
@end
