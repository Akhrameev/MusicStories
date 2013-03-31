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
    self.vkontakte = [Vkontakte sharedInstance];
    self.vkontakte.delegate = self;
    [self.webView setScalesPageToFit:YES];
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
    
    UIButton *buttonVK =  [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonVK setImage:[UIImage imageNamed:@"icon-Small"] forState:UIControlStateNormal];
    if (self.vkontakte.isAuthorized)
    {
        [buttonVK setImage:[UIImage imageNamed:@"icon-Small"] forState:UIControlStateNormal];
        [self.vkontakte getUserInfo];
    }
    else
        [buttonVK setImage:[UIImage imageNamed:@"icon-Small-off"] forState:UIControlStateNormal];
    [buttonVK addTarget:self action:@selector(vkLogin:) forControlEvents:UIControlEventTouchUpInside];
    [buttonVK setFrame:CGRectMake(280, 25, 30, 30)];
    UIBarButtonItem *vklogin = [[UIBarButtonItem alloc] initWithCustomView:buttonVK];
    if (self.vkontakte.isAuthorized)
    {
        UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sendImageToVkontakte:)];
        [share setTintColor:[UIColor colorWithRed:40/255.0 green:106/255.0 blue:161/255.0 alpha:0.5]];
        [self.navigationItem setRightBarButtonItems:@[refresh, trash, vklogin, share] animated:YES];
    }
    else
        [self.navigationItem setRightBarButtonItems:@[refresh, trash, vklogin] animated:YES];
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
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.spinner setColor:[UIColor grayColor]];
        [self.webView addSubview:self.spinner];
    }
    self.spinner.frame = self.view.frame;
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

- (void) vkLogin: (id) sender
{
    if (![self.vkontakte isAuthorized])
        [self.vkontakte authenticate];
    else
        [self.vkontakte logout];
}

- (void) clearCache: (id) sender
{
    //TODO alert
    [Settings clearCache];
}

#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showVkontakteAuthController:(UIViewController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentModalViewController:controller animated:YES];
}

- (void)vkontakteAuthControllerDidCancelled
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte
{
    [self dismissModalViewControllerAnimated:YES];
    [self configureNavigationBar];
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte
{
    [self configureNavigationBar];
}

- (void)vkontakteDidFinishGettinUserInfo:(NSDictionary *)info
{
    NSLog(@"%@", info);
    
    /*NSString *photoUrl = [info objectForKey:@"photo_big"];
    NSData *photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];
    _userImage.image = [UIImage imageWithData:photoData];
    
    _userName.text = [info objectForKey:@"first_name"];
    _userSurName.text = [info objectForKey:@"last_name"];
    _userBDate.text = [info objectForKey:@"bdate"];
    _userGender.text = [NSString stringWithGenderId:[[info objectForKey:@"sex"] intValue]];*/
}

- (void)vkontakteDidFinishPostingToWall:(NSDictionary *)responce
{
    NSLog(@"%@", responce);
}

- (void) sendImageToVkontakte: (id) sender
{
    if (![self.vkontakte isAuthorized])
        [self.vkontakte authenticate];
    else
    {
        NSString *message = @"Я сейчас играю: ";
        message = [message stringByAppendingString:self.instrument.linkComposition.name];
        [self.vkontakte postImageToWall:[UIImage imageNamed:@"MusicStories"]
                                   text:message
                                   link:[NSURL URLWithString:self.instrument.url]];
    }
}

@end
