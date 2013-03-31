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
@property (strong, nonatomic) NSDictionary *userInfo;
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
    //UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadWebView:)];
    UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearCache:)];
    UIBarButtonItem *vklogin = nil;
    if (self.vkontakte.isAuthorized)
    {
        if (!self.userInfo)
            [self.vkontakte getUserInfo];
        NSString *name = @"Выйти";
        if (self.userInfo)
        {
            NSString *firstName = [self.userInfo objectForKey:@"first_name"];
            NSString *lastName = [self.userInfo objectForKey:@"last_name"];
            name = [[firstName stringByAppendingString:@" "] stringByAppendingString:lastName];
        }
        vklogin = [[UIBarButtonItem alloc] initWithTitle:name style:UIBarButtonItemStyleBordered target:self action:@selector(vkLogin:)];
        [vklogin setTintColor:[self vkBlueColor]];
    }
    else
    {
        vklogin = [[UIBarButtonItem alloc] initWithTitle:@"Войти вконтакте" style:UIBarButtonItemStyleBordered target:self action:@selector(vkLogin:)];
    }
    if (self.vkontakte.isAuthorized)
    {
        UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sendImageToVkontakte:)];
        [share setTintColor:[self vkBlueColor]];
        [self.navigationItem setRightBarButtonItems:@[/*refresh,*/ trash, share, vklogin] animated:YES];
    }
    else
        [self.navigationItem setRightBarButtonItems:@[/*refresh,*/ trash, vklogin] animated:YES];
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
    self.spinner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

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
        return;
    }
    if (alertView.tag == 2)
    {
        if (buttonIndex == 1)
        {
            [self.vkontakte logout];
            self.userInfo = nil;
        }
        return;
    }
    if (alertView.tag == 3)
    {
        if (buttonIndex == 1)
            [Settings clearCache];
        return;
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
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Выйти из вконтакте?"
                                                       message: nil
                                                      delegate: self
                                             cancelButtonTitle: @"Отменить"
                                             otherButtonTitles: @"OK",nil];
        [alert setTag:2];
        [alert show];
    }
}

- (void) clearCache: (id) sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Очистить все загруженные ноты?"
                                                   message: nil
                                                  delegate: self
                                         cancelButtonTitle: @"Отменить"
                                         otherButtonTitles: @"OK",nil];
    [alert setTag:3];
    [alert show];
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
    self.userInfo = info;
    [self configureNavigationBar];
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
        message = [message stringByAppendingString:@" (MusicStories for iPad)"];
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        CGRect rect = [keyWindow bounds];
        UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [keyWindow.layer renderInContext:context];
        UIImage *capturedScreen = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (!capturedScreen)
            capturedScreen = [UIImage imageNamed:@"MS-144"];
        [self.vkontakte postImageToWall:capturedScreen
                                   text:message
                                   link:[NSURL URLWithString:self.instrument.url]];
    }
}


- (UIColor *) vkBlueColor
{
    return [UIColor colorWithRed:69/255.0 green:150/255.0 blue:217/255.0 alpha:1];
}
@end
