//
//  MSUDetailViewController.h
//  MusicStories
//
//  Created by Me Interactive on 03.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "Composition+Ext.h"

@interface MSUDetailViewController : UIViewController <UISplitViewControllerDelegate, iCarouselDataSource, iCarouselDelegate>
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) Composition *composition;
@end
