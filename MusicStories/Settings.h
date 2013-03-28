//
//  Settings.h
//  MusicStories
//
//  Created by Me Interactive on 28.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Instrument;

@interface Settings : NSManagedObject

@property (nonatomic, retain) NSNumber * lastUpdate;
@property (nonatomic, retain) Instrument *linkLastOpened;

@end
