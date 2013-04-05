//
//  MSUDetailViewController.m
//  MusicStories
//
//  Created by Me Interactive on 03.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "MSUDetailViewController.h"
#import "Instrument+Ext.h"
#import "Settings+Ext.h"

@interface MSUDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void) configureView;
@property (nonatomic, strong) NSArray *arrayInstruments;
@property (nonatomic, strong) Instrument *instrument;
@property (nonatomic, strong) Instrument *lastOpenedInstrument;
@end

@implementation MSUDetailViewController

@synthesize composition = _composition;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setComposition:(Composition *)composition
{
    if (self.composition != composition)
    {
        _composition = composition;
        self.arrayInstruments = nil;
        self.lastOpenedInstrument = nil;
        [self configureView];
    }
    if (self.masterPopoverController != nil)
        [self.masterPopoverController dismissPopoverAnimated:YES];
}

- (void) updateLastOpenedInstrument
{
    NSNumber *lastOpenedId = [[Settings settings] lastOpened];
    self.lastOpenedInstrument = [Instrument MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"id == %@" argumentArray:@[lastOpenedId]]];
}

- (void) configureView
{
    self.carousel.type = iCarouselTypeRotary;
    [self.carousel setCenterItemWhenSelected:YES];
    if (!self.arrayInstruments)
        [self updateArrayInstruments];
    [self configureNavigationBar];
    [self.carousel reloadData];
    if (!self.lastOpenedInstrument)
        [self updateLastOpenedInstrument];
    if ([self.lastOpenedInstrument.linkComposition isEqual:self.composition])
    {
        NSInteger index = 0;
        for (Instrument *instrumentIt in self.arrayInstruments)
        {
            if ([instrumentIt isEqual:self.lastOpenedInstrument])
                [self.carousel scrollToItemAtIndex:index animated:YES];
            ++index;
        }
    }
    [self configureEmptyCarouselView];
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
    [self configureEmptyCarouselView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Список композиций";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = pc;
}

- (void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void) updateArrayInstruments
{
    self.arrayInstruments = [self.composition.listInstuments sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
}

- (void) configureNavigationBar
{
    [self.navigationItem setTitle:self.composition.name];
}


- (void) viewWillAppear:(BOOL)animated
{
    [self configureEmptyCarouselView];
    [super viewWillAppear:animated];
}

- (void) configureEmptyCarouselView
{
    UITextView *view = (UITextView *)[self.carousel viewWithTag:NSIntegerMax];
    if ([view.text isEqualToString:@""])
    {
        [view setFrame:CGRectMake(0, 0, 0, 0)];
        return;
    }
    CGRect frame = [self.view frame];
    if (frame.size.width >= 300)
        frame.size.width = 300;
    CGSize textSize = [view.text sizeWithFont:view.font constrainedToSize:frame.size lineBreakMode:NSLineBreakByWordWrapping];
    frame.origin.y = (frame.size.height - textSize.height)/2;
    frame.origin.x = (self.view.frame.size.width - textSize.width)/2;
    view.frame = frame;
}
#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    if (!self.arrayInstruments)
        [self updateArrayInstruments];
    UITextView *textview = (UITextView *)[self.carousel viewWithTag:NSIntegerMax];
    if (!textview)
    {
        textview = [[UITextView alloc] init];
        [textview setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [textview setTag:NSIntegerMax];
        [textview setUserInteractionEnabled:NO];
        [textview setFont:[UIFont systemFontOfSize:16]];
        [textview setTextAlignment:NSTextAlignmentCenter];
        [self.carousel addSubview:textview];
    }
    if ([self.arrayInstruments count])
        [textview setText:@""];
    else
        [textview setText:@"Выберите композицию. Здесь вы сможете выбрать партию, доступную для выбранной композиции."];
    return [self.arrayInstruments count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)];
        ((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
        view.contentMode = UIViewContentModeCenter;
        CGRect frame = view.bounds;
        frame.origin.y = frame.origin.y + frame.size.height;
        frame.size.height = 50;
        label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:20];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    Instrument *instrument = [self.arrayInstruments objectAtIndex:index];
    [((UIImageView *)view) setImage:[UIImage imageNamed:[self getPathForInstrumentPic: instrument.pic.integerValue]]];
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = instrument.name;
    return view;
}

- (NSString *) getPathForInstrumentPic : (NSUInteger) id
{
    NSArray *array = @[@"music_instruments.png", @"violin.png", @"viola.png", @"royal.png"];
    if (id >= [array count])
        id = 0;
    return [array objectAtIndex:id];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    self.instrument = [self.arrayInstruments objectAtIndex:index];
    [self.splitViewController performSegueWithIdentifier:@"segueNotes" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueNotes"])
        [segue.destinationViewController setInstrument:self.instrument];
    [super prepareForSegue:segue sender:sender];
}

- (Instrument *) instrumentForSegue
{
    return self.instrument;
}

@end
