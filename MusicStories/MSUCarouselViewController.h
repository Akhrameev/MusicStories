//
//  MSUCarouselViewController.h
//  MusicStories
//
//  Created by Me Interactive on 25.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "Composition+Ext.h"

@interface MSUCarouselViewController : UIViewController
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) Composition *composition;
@end
