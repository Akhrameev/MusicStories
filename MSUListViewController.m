//
//  MSUListViewController.m
//  MusicStories
//
//  Created by Me Interactive on 25.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "MSUListViewController.h"
#import "MSUCompositionData.h"
#import "MSUCarouselViewController.h"
#import "MSUWebViewViewController.h"

//#define NEWS_URL @"https://api.tcsbank.ru/v1/news"              //from this link I will get data
#define NEWS_URL @"https://s3.amazonaws.com/MusicNotes/config.txt"
#define AUTOLOAD_ON_START                                       //download or not data immediately on startup


@interface MSUListViewController ()
@property (strong, nonatomic) NSURLConnection *urlconnection;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) MSUCompositionData *composition;
@end

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
#ifdef AUTOLOAD_ON_START
    [self.refreshControl beginRefreshing];
    [self refreshView: self.refreshControl];
#endif
}

- (IBAction)refreshView:(UIRefreshControl *)refresh;
{
    //styling refreshView
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Данные обновляются..."];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Последнее обновление: %@",
                             [formatter stringFromDate:[NSDate date]]];
    [refresh setAttributedTitle: [[NSAttributedString alloc] initWithString:lastUpdated]];
    
    //get request to get data
    self.responseData = [NSMutableData data];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:NEWS_URL]];
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
    //data is in responseData, so parse it
    /*NSString *testResponse = @"{\"compositions\":[{\"compositor\":\"Паганини\",\"name\":\"№ 7, ми мажор\",\"instruments\":[{\"name\":\"Гитара\",\"id\":1,\"url\":\"http://nsidc.org/pubs/notes/64/Notes_64_web.pdf\"}]}]}";
    NSString *testResponseUtf8 =  [NSString stringWithUTF8String:[testResponse UTF8String]];
    NSData *responseData = [testResponseUtf8 dataUsingEncoding: NSUTF8StringEncoding];
    self.responseData = [responseData mutableCopy];*/
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    if (myError)
    {
        //alert user about parse error and stop visualizing refreshing
        [self.refreshControl endRefreshing];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Parse error" message:[myError description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    NSArray *compositions = [res objectForKey:@"compositions"];
    //enter root element, then make a loop of its elements
    NSMutableArray *compositionsMutable = [NSMutableArray array];
    for (NSDictionary *item in compositions)
    {
        MSUCompositionData *composition = [MSUCompositionData initWithDictianary:item];
        [compositionsMutable addObject:composition];
    }
    self.tableData = compositionsMutable;
    [self.table reloadData];
    [self.refreshControl endRefreshing];
    
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellComposition" forIndexPath:indexPath];
    MSUCompositionData *composition = [self.tableData objectAtIndex:indexPath.row];
    cell.textLabel.text = composition.compositor;
    cell.detailTextLabel.text = composition.name;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.composition = [self.tableData objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"segueInstrument" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueInstrument"])
        [segue.destinationViewController setComposition:self.composition];
    [super prepareForSegue:segue sender:sender];
}

@end
