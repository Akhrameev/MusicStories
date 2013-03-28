//
//  Instrument+Ext.h
//  MusicStories
//
//  Created by Me Interactive on 28.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "Instrument.h"

@interface Instrument (Ext)
+ (Instrument *) syncFromDict: (NSDictionary *) dict;
- (void) deleteWithChilds;
@end
