//
//  MSUCompositionData.m
//  MusicStories
//
//  Created by Me Interactive on 25.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "MSUCompositionData.h"

@implementation MSUCompositionData
@synthesize compositor;
@synthesize name;
@synthesize instruments;

+ (MSUCompositionData *) initWithDictianary: (NSDictionary *) dictianary
{
    MSUCompositionData *composition = [[MSUCompositionData alloc] init];
    id temp = [dictianary objectForKey:@"compositor"];
    if (temp)
        [composition setCompositor:temp];
    temp = [dictianary objectForKey:@"name"];
    if (temp)
        [composition setName:temp];
    temp = [dictianary objectForKey:@"instruments"];
    if (temp)
        [composition setInstruments:temp];
    return composition;
}
@end
