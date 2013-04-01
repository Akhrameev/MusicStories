//
//  UIImage+Resize.m
//  MusicStories
//
//  Created by Me Interactive on 02.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)
- (UIImage *) resizeToSize: (CGSize) size
{
    if (self.size.height == size.height && self.size.width == size.width)
        return self;
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
