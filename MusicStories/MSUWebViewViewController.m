//
//  MSUWebViewViewController.m
//  MusicStories
//
//  Created by Me Interactive on 26.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "MSUWebViewViewController.h"
#import "Settings+Ext.h"
#import "Composition+Ext.h"

@interface MSUWebViewViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSURLConnection *urlconnection;
@property (strong, nonatomic) NSMutableData *responseData;
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
    [self webViewDidStartLoad:self.webView];
    [self loadWebView];
    //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.instrument.url]]];
	// Do any additional setup after loading the view.
}

- (void) loadWebView
{
    NSData *dataFromCache = [Settings dataFromCacheForURL:self.instrument.url];
    if (dataFromCache)
        [self.webView loadData:dataFromCache MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
    else
    {
        self.responseData = [NSMutableData data];
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:self.instrument.url]];
        self.urlconnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void) reloadWebView
{
    [Settings clearDataFromCacheForURL:self.instrument.url];
    self.responseData = [NSMutableData data];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:self.instrument.url]];
    self.urlconnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //clear responseData on response
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //append new data to responseData
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //alert view to show error to user, and stop visualizing refreshing on error
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Network error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [Settings saveDataInCacheFromURL:self.instrument.url :self.responseData];
    [self loadWebView];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self configureNavigationBar];
    [super viewWillAppear:animated];
}

- (void) configureNavigationBar
{
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadWebView:)];
    UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearCache:)];
    [self.navigationItem setRightBarButtonItems:@[refresh, trash] animated:YES];
    [self.navigationItem setTitle:self.instrument.linkComposition.name];
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
        CGRect frame = [self.view frame];
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
    [[Settings settings] setLastOpened:self.instrument.id];
    [Settings save];
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
            [self reloadWebView:self];
    }
}

- (void) reloadWebView: (id) sender
{
    [self reloadWebView];
}

- (void) clearCache: (id) sender
{
    //TODO alert
    [Settings clearCache];
}

@end
