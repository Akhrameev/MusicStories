//
//  VkData.h
//  MusicStories
//
//  Created by Me Interactive on 01.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Settings;

@interface VkData : NSManagedObject

@property (nonatomic, retain) NSString * bdate;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSString * photoBigUrl;
@property (nonatomic, retain) NSData * photoBigData;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSString * sexString;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) Settings *linkSettings;

@end
