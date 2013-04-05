//
//  MSUCarouselContainerView.m
//  MusicStories
//
//  Created by Me Interactive on 05.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "MSUCarouselContainerView.h"
#import "iCarousel.h"

@implementation MSUCarouselContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addGestureRecognizers];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self addGestureRecognizers];
    }
    return self;
}

- (void) addGestureRecognizers
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEnded:)];
    [self addGestureRecognizer:panRecognizer];
    /*CGRect swipeArea = self.frame;
    swipeArea.origin.x += swipeArea.size.width/5;
    swipeArea.size.width -= swipeArea.size.width/5;
    UIView *swipableView = [[UIView alloc] initWithFrame:swipeArea];
    [self addSubview:swipableView];
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeEnded:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight ];
    [swipeRecognizer setNumberOfTouchesRequired:1];
    [swipableView addGestureRecognizer:swipeRecognizer];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEnded:)];
    [tapRecognizer setEnabled:NO];
    [swipableView addGestureRecognizer:tapRecognizer];*/
}

- (void) panEnded: (UIPanGestureRecognizer *) recognizer
{
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews)
        if ([subview isKindOfClass:[iCarousel class]])
            [((iCarousel *) subview) didPan:recognizer]; 
}

- (void) swipeEnded: (UISwipeGestureRecognizer *) recognizer
{
    //NSLog(@"Swipe: %d\n", (NSInteger)recognizer.state);
}

- (void) tapEnded: (UITapGestureRecognizer *) recognizer
{
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews)
        if ([subview isKindOfClass:[iCarousel class]])
            [((iCarousel *) subview) didTap:recognizer];
}
@end
