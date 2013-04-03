//
//  MSUWebViewController.m
//  MusicStories
//
//  Created by Me Interactive on 03.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "MSUWebViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "Settings+Ext.h"
#import "Composition+Ext.h"
#import "Compositor+Ext.h"
#import "VkData+Ext.h"
#import "UIImage+Resize.h"
#import "UIImage+rotate.h"

@interface MSUWebViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSURLConnection *urlconnection;
@property (strong, nonatomic) NSMutableData *responseData;
@property (weak, nonatomic) VkData *vkData;
@end

@implementation MSUWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.vkontakte = [Vkontakte sharedInstance];
    self.vkontakte.delegate = self;
    [self.webView setScalesPageToFit:YES];
    [self startSpinning];
	[self loadWebView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self configureToolbar];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) startSpinning
{
    if (!self.spinner)
    {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.spinner setColor:[UIColor grayColor]];
        [self.webView addSubview:self.spinner];
    }
    self.spinner.bounds = self.view.bounds;
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
            self.vkData = nil;
        }
        return;
    }
    if (alertView.tag == 3)
    {
        if (buttonIndex == 1)
            [Settings clearDataFromCacheForURL: self.instrument.url];
        return;
    }
}

- (void) reloadWebView: (id) sender
{
    [self reloadWebView];
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
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Очистить загруженные ноты?"
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showVkontakteAuthController:(UIViewController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)vkontakteAuthControllerDidCancelled
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self configureToolbar];
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte
{
    [self configureToolbar];
}

- (void)vkontakteDidFinishGettinUserInfo:(NSDictionary *)info
{
    NSLog(@"%@", info);
    self.vkData = [Settings vkDataWithDict:info];
    [self configureToolbar];
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
        Compositor *compositor = (Compositor *)self.instrument.linkComposition.linkCompositor;
        NSString *compositor_name = [compositor name];
        message = [message stringByAppendingString:compositor_name];
        message = [message stringByAppendingString:@" - "];
        message = [message stringByAppendingString:self.instrument.linkComposition.name];
        message = [message stringByAppendingString:@" (MusicStories for iPad)"];
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        CGRect rect = [keyWindow bounds];
        UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [keyWindow.layer renderInContext:context];
        UIImage *capturedScreen = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (capturedScreen)
            capturedScreen = [capturedScreen rotateToDeviceOrientation:[[UIDevice currentDevice] orientation]];
        if (!capturedScreen)
            capturedScreen = [UIImage imageNamed:@"MS-144"];
        [self.vkontakte postImageToWall:capturedScreen
                                   text:message
                                   link:[NSURL URLWithString:self.instrument.url]];
    }
}

- (void) configureToolbar
{
    //UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadWebView:)];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonClick:)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, self.view.frame.size.width/2, 21.0f)];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0]];
    [titleLabel setText:self.instrument.linkComposition.name];          //set text
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearCache:)];
    UIBarButtonItem *vklogin = nil;
    if (self.vkontakte.isAuthorized)
    {
        if (!self.vkData)
            [self.vkontakte getUserInfo];
        NSString *name = @"Выйти";
        if (self.vkData)
        {
            NSString *firstName = self.vkData.firstName;
            NSString *lastName = self.vkData.lastName;
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
        if (self.vkData.photo)
        {
            UIImage *faceImage = self.vkData.photo;
            NSInteger height = /*self.toolbar.frame.size.height*/ 44 - 10;
            faceImage = [faceImage resizeToSize:CGSizeMake(height, height)];
            UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
            [face setShowsTouchWhenHighlighted:NO];
            [face setUserInteractionEnabled:NO];
            face.bounds = CGRectMake(0, 0, faceImage.size.width, faceImage.size.height);
            [face setImage:faceImage forState:UIControlStateNormal];
            UIBarButtonItem *vkphoto = [[UIBarButtonItem alloc] initWithCustomView:face];
            [self.toolbar setItems:@[back, spacer1, title, spacer2, /*refresh,*/ vkphoto, vklogin, share, trash] animated:YES];
        }
        else
            [self.toolbar setItems:@[back, spacer1, title, spacer2, /*refresh,*/ vklogin, share, trash] animated:YES];
    }
    else
        [self.toolbar setItems:@[back, spacer1, title, spacer2, /*refresh,*/ vklogin, trash] animated:YES];
}

- (UIColor *) vkBlueColor
{
    return [UIColor colorWithRed:69/255.0 green:150/255.0 blue:217/255.0 alpha:1];
}

- (IBAction)backButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
