//
//  MSUCompositionData.h
//  MusicStories
//
//  Created by Me Interactive on 25.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSUCompositionData : NSObject
@property (strong, nonatomic) NSString  *compositor;
@property (strong, nonatomic) NSString  *name;
@property (strong, nonatomic) NSArray   *instruments;
@property (strong, nonatomic) NSNumber  *instrumentNo;
+ (MSUCompositionData *) initWithDictianary: (NSDictionary *) dictianary;     //method to parse NSDictionary, got from server

@end
