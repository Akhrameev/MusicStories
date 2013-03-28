//
//  Compositor.h
//  MusicStories
//
//  Created by Me Interactive on 28.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Composition;

@interface Compositor : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *listCompositions;
@end

@interface Compositor (CoreDataGeneratedAccessors)

- (void)addListCompositionsObject:(Composition *)value;
- (void)removeListCompositionsObject:(Composition *)value;
- (void)addListCompositions:(NSSet *)values;
- (void)removeListCompositions:(NSSet *)values;

@end
