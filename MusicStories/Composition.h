//
//  Composition.h
//  MusicStories
//
//  Created by Me Interactive on 28.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Composition : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSManagedObject *linkCompositor;
@property (nonatomic, retain) NSSet *listInstuments;
@end

@interface Composition (CoreDataGeneratedAccessors)

- (void)addListInstumentsObject:(NSManagedObject *)value;
- (void)removeListInstumentsObject:(NSManagedObject *)value;
- (void)addListInstuments:(NSSet *)values;
- (void)removeListInstuments:(NSSet *)values;

@end
