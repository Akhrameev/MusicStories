//
//  MSUWebViewViewController.h
//  MusicStories
//
//  Created by Me Interactive on 26.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"
#import "Instrument+Ext.h"
#import "Vkontakte.h"

@interface MSUWebViewViewController : UIViewController <UIWebViewDelegate, VkontakteDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) Instrument *instrument;
@property Vkontakte *vkontakte;
@end
