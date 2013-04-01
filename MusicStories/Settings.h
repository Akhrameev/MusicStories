//
//  Settings.h
//  MusicStories
//
//  Created by Me Interactive on 01.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CachedData, VkData;

@interface Settings : NSManagedObject

@property (nonatomic, retain) NSDate * lastDateUpdate;
@property (nonatomic, retain) NSDate * lastIntroductionShown;
@property (nonatomic, retain) NSNumber * lastOpened;
@property (nonatomic, retain) NSNumber * lastUpdate;
@property (nonatomic, retain) NSSet *listCachedData;
@property (nonatomic, retain) NSSet *listVkData;
@end

@interface Settings (CoreDataGeneratedAccessors)

- (void)addListCachedDataObject:(CachedData *)value;
- (void)removeListCachedDataObject:(CachedData *)value;
- (void)addListCachedData:(NSSet *)values;
- (void)removeListCachedData:(NSSet *)values;

- (void)addListVkDataObject:(VkData *)value;
- (void)removeListVkDataObject:(VkData *)value;
- (void)addListVkData:(NSSet *)values;
- (void)removeListVkData:(NSSet *)values;

@end
