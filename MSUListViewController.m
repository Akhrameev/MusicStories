//
//  MSUListViewController.m
//  MusicStories
//
//  Created by Me Interactive on 25.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "MSUListViewController.h"
#import "Compositor+Ext.h"
#import "Composition+Ext.h"
#import "Instrument+Ext.h"
#import "Settings+Ext.h"
#import "MSUCarouselViewController.h"
#import "MSUWebViewViewController.h"

//#define NEWS_URL @"https://api.tcsbank.ru/v1/news"              //from this link I will get data
#define NEWS_URL @"https://s3.amazonaws.com/MusicNotes/config.json"
#define DATE_URL @"https://s3.amazonaws.com/MusicNotes/date.txt"
#define AUTOLOAD_ON_START                                       //download or not data immediately on startup

@interface MSUListViewController ()
@property (strong, nonatomic) NSURLConnection *urlconnection;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) Composition *composition;
@property (strong, nonatomic) NSArray *compositors;
@property (strong, nonatomic) Compositor *targetCompositor;
@property (strong, nonatomic) NSArray *targetCompositorCompositions;
@property (strong, nonatomic) Instrument *lastOpenedInstrument;
@property NSInteger currentRequestType;
@property (strong, nonatomic) MYIntroductionView *introductionView;
@end

enum requestType {REQUEST_TYPE_DATE, REQUEST_TYPE_COMPOSITORS};

@implementation MSUListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //refreshView method will be used on pulling-to-refresh our table
    if (!self.refreshControl)
    {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.table addSubview:self.refreshControl];
    }
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];

    if (![self.compositors count])
        [self updateCompositors];
#ifdef AUTOLOAD_ON_START
    if (![self.compositors count])
    {
        [self.refreshControl beginRefreshing];
        [self refreshView: self.refreshControl];
    }
#endif
}

- (void) viewWillAppear:(BOOL)animated
{
    if ([Settings showIntroduction])
        [self showIntroduction];
    else
        [self configureNavigationBar];
    if (!self.lastOpenedInstrument)
        [self updateLastOpenedInstrument];
}

- (void) showIntroduction
{
    self.navigationItem.rightBarButtonItems = nil;
    [self.navigationItem setTitle:@"Music Stories"];
    //STEP 1 Construct Panels
    MYIntroductionPanel *panel = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"SampleImage1"] description:@"Welcome to MYIntroductionView, your 100 percent customizable interface for introductions and tutorials! Simply add a few classes to your project, and you are ready to go!"];
    
    //You may also add in a title for each panel
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"SampleImage2"] title:@"Your Ticket!" description:@"MYIntroductionView is your ticket to a great tutorial or introduction!"];
    
    //STEP 2 Create IntroductionView
    
    self.introductionView = [[MYIntroductionView alloc] initWithFrame:self.view.bounds headerText:@"" panels:@[panel, panel2] languageDirection:MYLanguageDirectionLeftToRight];
    
    [self.introductionView setBackgroundImage:[UIImage imageNamed:@"SampleBackground"]];
    [self recursiveAutoresizeSubviews:self.introductionView :UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    self.introductionView.delegate = self;
    
    [self.introductionView showInView:self.view];
}

- (void) recursiveAutoresizeSubviews: (UIView *) view : (NSInteger) mask
{
    [view setAutoresizingMask:mask];
    for (UIView *subview in view.subviews)
        [self recursiveAutoresizeSubviews: subview : mask];
}

- (void) configureNavigationBar
{
    [self.navigationItem setTitle:@"Список композиций"];
    UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearStoredData:)];
    if (self.lastOpenedInstrument)
    {
        UIBarButtonItem *lastOpened = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(lastOpenedClick:)];
        self.navigationItem.rightBarButtonItems = @[trash, lastOpened];
    }
    else
        self.navigationItem.rightBarButtonItems = @[trash];
}

- (void) lastOpenedClick: (id) sender
{
    if (!self.lastOpenedInstrument)
        [self updateLastOpenedInstrument];
    if (!self.lastOpenedInstrument)
        return;
    [self performSegueWithIdentifier:@"segueNotes" sender:self];
}

- (void) clearStoredData: (id) sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Очистить список композиций?"
                                                   message: nil
                                                  delegate: self
                                         cancelButtonTitle: @"Отменить"
                                         otherButtonTitles: @"OK",nil];
    [alert setTag:1];
    [alert show];
}

- (void) clearStoredData
{
    if (![self.compositors count])
        [self updateCompositors];
    [[Settings settings] setLastUpdate:@(-1)];
    [Settings save];
    for (Compositor *compositor in self.compositors)
        [compositor deleteWithChilds];
    [self updateCompositors];
    [self.table reloadData];
    [self.refreshControl beginRefreshing];
    [self refreshView: self.refreshControl];
}

- (void) updateCompositors
{
    self.compositors = [Compositor MR_findAllSortedBy:@"name" ascending:YES];
}

- (void) updateLastOpenedInstrument
{
    NSNumber *lastOpenedId = [[Settings settings] lastOpened];
    self.lastOpenedInstrument = [Instrument MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"id == %@" argumentArray:@[lastOpenedId]]];
}

- (IBAction)refreshView:(UIRefreshControl *)refresh;
{
    //styling refreshView
    static BOOL refreshed;
    if (refreshed)
    {
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Данные обновляются..."];
        NSDate *date = [Settings settings].lastDateUpdate;
        if (date)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            //[formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru"]];
            
            NSString *lastUpdated = [NSString stringWithFormat:@"Последнее обновление: %@",
                                     [formatter stringFromDate:[Settings settings].lastDateUpdate]];
            [refresh setAttributedTitle: [[NSAttributedString alloc] initWithString:lastUpdated]];
        }
    }
    else
    {
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@" "];
    }
    refreshed = YES;
    //get request to get data
    self.responseData = [NSMutableData data];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:DATE_URL]];
    self.currentRequestType = REQUEST_TYPE_DATE;
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
    [self.refreshControl endRefreshing];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Network error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection != self.urlconnection)
        return;
    if (self.currentRequestType == REQUEST_TYPE_COMPOSITORS)
        [self connectionDidFinishLoadingCompositors:connection];
    else if (self.currentRequestType == REQUEST_TYPE_DATE)
        [self connectionDidFinishLoadingDate:connection];
}

- (void)connectionDidFinishLoadingCompositors:(NSURLConnection *)connection
{
    //data is in responseData, so parse it
    //NSString *temp_str = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    //temp_str = [self stringByDecodingHTMLEntitiesInString:temp_str];
    //self.responseData = [[temp_str dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    if (myError)
    {
        //alert user about parse error and stop visualizing refreshing
        [self.refreshControl endRefreshing];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Parse error" message:[myError description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self.refreshControl endRefreshing];

        [alert show];
        return;
    }
    NSNumber *date = [res objectForKey:@"date"];
    [[Settings settings] setLastUpdate:date];
    NSArray *compositors = [res objectForKey:@"compositors"];
    if (![self.compositors count])
        [self updateCompositors];
    for (Compositor *compositor in self.compositors)
        [compositor deleteWithChilds];
    NSMutableArray *compositorsMutable = [NSMutableArray array];
    for (NSDictionary *item in compositors)
    {
        Compositor *compositor = [Compositor syncFromDict:item];
        [compositorsMutable addObject:compositor];
    }
    self.compositors = compositorsMutable;
    [self.table reloadData];
    [self.refreshControl endRefreshing];
}

- (void)connectionDidFinishLoadingDate:(NSURLConnection *)connection
{
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    if (myError)
    {
        //alert user about parse error and stop visualizing refreshing
        [self.refreshControl endRefreshing];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Date parse error" message:[myError description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self.refreshControl endRefreshing];
        [alert show];
        return;
    }
    [self.refreshControl endRefreshing];
    [[Settings settings] setLastDateUpdate:[NSDate date]];
    [Settings save];
    NSNumber *date = [res objectForKey:@"date"];
    if ([[Settings settings] lastUpdate].integerValue >= date.integerValue)
        return;
    self.responseData = [NSMutableData data];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:NEWS_URL]];
    self.currentRequestType = REQUEST_TYPE_COMPOSITORS;
    self.urlconnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTable:nil];
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.compositors count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellComposition" forIndexPath:indexPath];
    Compositor *compositor = [self.compositors objectAtIndex:indexPath.section];
    if (![compositor isEqual:self.targetCompositor] || !self.targetCompositorCompositions)
    {
        self.targetCompositor = compositor;
        self.targetCompositorCompositions = [compositor.listCompositions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    }
    Composition *composition = [self.targetCompositorCompositions objectAtIndex:indexPath.row];
    //cell.detailTextLabel.text = compositor.name;
    cell.textLabel.text = composition.name;   
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.compositors objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.compositors objectAtIndex:section] listCompositions] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Compositor *compositor = [self.compositors objectAtIndex:indexPath.section];
    if (![compositor isEqual:self.targetCompositor] || !self.targetCompositorCompositions)
    {
        self.targetCompositor = compositor;
        self.targetCompositorCompositions = [compositor.listCompositions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    }
    self.composition = [self.targetCompositorCompositions objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"segueInstrument" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueInstrument"])
        [segue.destinationViewController setComposition:self.composition];
    else if ([[segue identifier] isEqualToString:@"segueNotes"])
        [segue.destinationViewController setInstrument:self.lastOpenedInstrument];
    [super prepareForSegue:segue sender:sender];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (buttonIndex == 1)
        {
            [self clearStoredData];
        }
        return;
    }
}

- (NSString *)stringByDecodingHTMLEntitiesInString:(NSString *)input {
    NSMutableString *results = [NSMutableString string];
    NSScanner *scanner = [NSScanner scannerWithString:input];
    [scanner setCharactersToBeSkipped:nil];
    while (![scanner isAtEnd]) {
        NSString *temp;
        if ([scanner scanUpToString:@"&" intoString:&temp]) {
            [results appendString:temp];
        }
        if ([scanner scanString:@"&" intoString:NULL]) {
            BOOL valid = YES;
            unsigned c = 0;
            NSUInteger savedLocation = [scanner scanLocation];
            if ([scanner scanString:@"#" intoString:NULL]) {
                // it's a numeric entity
                if ([scanner scanString:@"x" intoString:NULL]) {
                    // hexadecimal
                    unsigned int value;
                    if ([scanner scanHexInt:&value]) {
                        c = value;
                    } else {
                        valid = NO;
                    }
                } else {
                    // decimal
                    int value;
                    if ([scanner scanInt:&value] && value >= 0) {
                        c = value;
                    } else {
                        valid = NO;
                    }
                }
                if (![scanner scanString:@";" intoString:NULL]) {
                    // not ;-terminated, bail out and emit the whole entity
                    valid = NO;
                }
            } else {
                if (![scanner scanUpToString:@";" intoString:&temp]) {
                    // &; is not a valid entity
                    valid = NO;
                } else if (![scanner scanString:@";" intoString:NULL]) {
                    // there was no trailing ;
                    valid = NO;
                } else if ([temp isEqualToString:@"amp"]) {
                    c = '&';
                } else if ([temp isEqualToString:@"quot"]) {
                    c = '"';
                } else if ([temp isEqualToString:@"lt"]) {
                    c = '<';
                } else if ([temp isEqualToString:@"gt"]) {
                    c = '>';
                } else {
                    // unknown entity
                    valid = NO;
                }
            }
            if (!valid) {
                // we errored, just emit the whole thing raw
                [results appendString:[input substringWithRange:NSMakeRange(savedLocation, [scanner scanLocation]-savedLocation)]];
            } else {
                [results appendFormat:@"%C", (unsigned short)c];
            }
        }
    }
    return results;
}

#pragma mark - Introduction Delegate Methods

-(void)introductionDidFinishWithType:(MYFinishType)finishType{
    if (finishType == MYFinishTypeSkipButton) {
        NSLog(@"Did Finish Introduction By Skipping It");
    }
    else if (finishType == MYFinishTypeSwipeOut){
        NSLog(@"Did Finish Introduction By Swiping Out");
    }
    [[Settings settings] setLastIntroductionShown:[NSDate date]];
    [Settings save];
    self.introductionView = nil;
    [self configureNavigationBar];
    //One might consider making the introductionview a class variable and releasing it here.
    // I didn't do this to keep things simple for the sake of example.
}

-(void)introductionDidChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    NSLog(@"%@ \nPanelIndex: %d", panel.Description, panelIndex);
}
@end
