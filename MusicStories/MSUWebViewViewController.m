//
//  MSUWebViewViewController.m
//  MusicStories
//
//  Created by Me Interactive on 26.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "MSUWebViewViewController.h"

@interface MSUWebViewViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation MSUWebViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.instrument.url]]];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (!self.spinner)
    {
        CGRect frame = [self.webView frame];
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.spinner setColor:[UIColor grayColor]];
        self.spinner.frame = frame;
        [self.webView addSubview:self.spinner];
    }
    [self.spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.spinner stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Ошибка звгрузки"
                                                   message: [error description]
                                                  delegate: self
                                         cancelButtonTitle: @"Обновить"
                                         otherButtonTitles: @"OK",nil];
    [alert setTag:1];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (buttonIndex == 0)
            [self.webView reload];
    }
}

@end
