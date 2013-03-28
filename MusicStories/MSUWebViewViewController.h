//
//  MSUWebViewViewController.h
//  MusicStories
//
//  Created by Me Interactive on 26.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSUCompositionData.h"

@interface MSUWebViewViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) MSUCompositionData *composition;
@end
