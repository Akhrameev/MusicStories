//
//  Settings+Ext.h
//  MusicStories
//
//  Created by Me Interactive on 28.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "Settings.h"

@interface Settings (Ext)
+ (Settings *) settings;
+ (void) save;
+ (NSData *) dataFromCacheForURL: (NSString *) url;
+ (void) saveDataInCacheFromURL: (NSString *) url : (NSData *) data;
+ (void) clearDataFromCacheForURL: (NSString *) url;
+ (void) clearCache;
@end
