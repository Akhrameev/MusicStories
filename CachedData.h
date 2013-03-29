//
//  CachedData.h
//  MusicStories
//
//  Created by Me Interactive on 29.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Settings;

@interface CachedData : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) Settings *linkSettings;

@end
