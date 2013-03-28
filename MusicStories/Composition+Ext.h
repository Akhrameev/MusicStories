//
//  Composition+Ext.h
//  MusicStories
//
//  Created by Me Interactive on 28.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "Composition.h"

@interface Composition (Ext)
+ (Composition *) syncFromDict: (NSDictionary *) dict;
- (void) deleteWithChilds;
@end
