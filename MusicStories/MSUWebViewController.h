//
//  MSUWebViewController.h
//  MusicStories
//
//  Created by Me Interactive on 03.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument+Ext.h"
#import "Vkontakte.h"

@interface MSUWebViewController : UIViewController <UIWebViewDelegate, VkontakteDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)backButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) Instrument *instrument;
@property Vkontakte *vkontakte;
@end
