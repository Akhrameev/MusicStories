//
//  UIImage+rotate.h
//  MusicStories
//
//  Created by Me Interactive on 03.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (rotate)
- (UIImage *) rotateToDeviceOrientation: (UIDeviceOrientation) deviceOrientation;
@end
