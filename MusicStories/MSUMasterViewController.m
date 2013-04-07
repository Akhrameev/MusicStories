//
//  MSUMasterViewController.m
//  MusicStories
//
//  Created by Me Interactive on 03.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "MSUMasterViewController.h"
#import "MSUDetailViewController.h"
#import "Compositor+Ext.h"
#import "Composition+Ext.h"
#import "Settings+Ext.h"
#import "Toast+UIView.h"

#define NEWS_URL @"https://s3.amazonaws.com/MusicNotes/config.json"
#define DATE_URL @"https://s3.amazonaws.com/MusicNotes/date.txt"
#define AUTOLOAD_ON_START                                       //download or not data immediately on startup

@interface MSUMasterViewController ()
@property (strong, nonatomic) NSURLConnection *urlconnection;
@property (strong, nonatomic) NSMutableData *responseData;
@property NSInteger currentRequestType;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) Composition *composition;
@property (strong, nonatomic) NSArray *compositors;
@property (strong, nonatomic) Compositor *targetCompositor;
@property (strong, nonatomic) NSArray *targetCompositorCompositions;
@end

enum requestType {REQUEST_TYPE_DATE, REQUEST_TYPE_COMPOSITORS};

@implementation MSUMasterViewController

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
    [self.navigationItem setTitle: @"Список композиций"];
    self.detailViewController = (MSUDetailViewController *) [[self.splitViewController.viewControllers lastObject] topViewController];
    //[self.table selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    if (!self.refreshControl)
    {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.table addSubview:self.refreshControl];
    }
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(deviceOrientationDidChangeNotification:)
        name:UIDeviceOrientationDidChangeNotification
        object:nil];
    if (![self.compositors count])
        [self updateCompositors];
#ifdef AUTOLOAD_ON_START
    if (![self.compositors count])
    {
        [self.refreshControl beginRefreshing];
        [self refreshView: self.refreshControl];
    }
#endif
    if ([self.compositors count])
    {
        if (!self.lastOpenedInstrument)
            [self updateLastOpenedInstrument];
        if (self.lastOpenedInstrument)
        {
            self.composition = self.lastOpenedInstrument.linkComposition;
            [self.detailViewController setComposition:self.composition];
        }
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    static NSInteger isInitialSelection = YES;
    if (!self.lastOpenedInstrument)
        [self updateLastOpenedInstrument];
    if ((isInitialSelection != 0) && self.lastOpenedInstrument)
    {
        Composition *selectedComposition = self.lastOpenedInstrument.linkComposition;
        Compositor *selectedCompositor = (Compositor *)selectedComposition.linkCompositor;
        NSInteger section = 0;
        NSInteger row = 0;
        for (Compositor *compositor in self.compositors)
        {
            if ([compositor isEqual:selectedCompositor])
            {
                if (![compositor isEqual:self.targetCompositor] || !self.targetCompositorCompositions)
                {
                    self.targetCompositor = compositor;
                    self.targetCompositorCompositions = [compositor.listCompositions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
                }
                for (Composition *compositionIt in self.targetCompositorCompositions)
                {
                    if ([compositionIt isEqual:selectedComposition])
                        [self.table selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                    ++row;
                }
            }
            ++section;
        }
    }
    isInitialSelection = 0;
    [self configureNavigationBar];
    [self configureEmptyCompositorsTable];
    [super viewWillAppear:animated];
}

- (void) updateLastOpenedInstrument
{
    NSNumber *lastOpenedId = [[Settings settings] lastOpened];
    self.lastOpenedInstrument = [Instrument MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"id == %@" argumentArray:@[lastOpenedId]]];
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateCompositors
{
    self.compositors = [Compositor MR_findAllSortedBy:@"name" ascending:YES];
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
    [self.refreshControl endRefreshing];
    [self.view makeToast:@""
                duration:2.0
                position:@"bottom"
                   title:@"Ошибка"];
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
        [self.refreshControl endRefreshing];
        [self.view makeToast:@"Не удалось разобрать бормотание сервера"
                    duration:3.0
                    position:@"bottom"
                       title:@"Ошибка!"];
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
        [self.refreshControl endRefreshing];
        [self.view makeToast:@"Не удалось разобрать бормотание сервера"
                    duration:3.0
                    position:@"bottom"
                       title:@"Ошибка!"];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    UITextView *textview = (UITextView *)[self.view viewWithTag:NSIntegerMax];
    if (!textview)
    {
        textview = [[UITextView alloc] init];
        [textview setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [textview setTag:NSIntegerMax];
        [textview setUserInteractionEnabled:NO];
        [textview setFont:[UIFont systemFontOfSize:16]];
        [textview setTextAlignment:NSTextAlignmentCenter];
        [textview setBackgroundColor:self.table.backgroundView.backgroundColor];
        
        [self.view addSubview:textview];
    }
    if ([self.compositors count])
        [textview setText:@""];
    else
        [textview setText:@"Потяните для обновления списка композиций."];
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
    [self.detailViewController setComposition:self.composition];
}

- (void) configureNavigationBar
{
    [self.navigationItem setTitle:@"Список композиций"];
    UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearStoredData:)];
    /*if (self.lastOpenedInstrument)
    {
        UIBarButtonItem *lastOpened = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(lastOpenedClick:)];
        self.navigationItem.rightBarButtonItems = @[trash, lastOpened];
    }
    else*/
        self.navigationItem.rightBarButtonItems = @[trash];
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

- (void) configureEmptyCompositorsTable
{
    UITextView *view = (UITextView *)[self.view viewWithTag:NSIntegerMax];
    if ([view.text isEqualToString:@""])
    {
        [view setFrame:CGRectMake(0, 0, 0, 0)];
        return;
    }
    CGRect frame = [self.view frame];
    if (frame.size.width >= 200)
        frame.size.width = 200;
    CGSize textSize = [view.text sizeWithFont:view.font constrainedToSize:frame.size lineBreakMode:NSLineBreakByWordWrapping];
    frame.origin.y = (frame.size.height - textSize.height)/2;
    frame.origin.x = (self.view.frame.size.width - textSize.width)/2;
    view.frame = frame;
}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
    [self configureEmptyCompositorsTable];
}

- (void) lastOpenedClick: (id) sender
{
    if (!self.lastOpenedInstrument)
        [self updateLastOpenedInstrument];
    if (!self.lastOpenedInstrument)
        return;
    [self.splitViewController performSegueWithIdentifier:@"segueNotes" sender:self];
}

- (Instrument *) instrumentForSegue
{
    return self.lastOpenedInstrument;
}

@end
