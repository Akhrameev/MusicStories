//
//  MSUCarouselViewController.m
//  MusicStories
//
//  Created by Me Interactive on 25.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "MSUCarouselViewController.h"
#import "Instrument+Ext.h"

@interface MSUCarouselViewController ()
@property (nonatomic, strong) NSArray *arrayInstruments;
@property (nonatomic, strong) Instrument *instrument;
@end

@implementation MSUCarouselViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)awakeFromNib
{
    //set up data
    //your carousel should always be driven by an array of
    //data of some kind - don't store data in your item views
    //or the recycling mechanism will destroy your data once
    //your item views move off-screen
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.carousel.type = iCarouselTypeRotary;
    [self.carousel setCenterItemWhenSelected:YES];
    if (!self.arrayInstruments)
        [self updateArrayInstruments];
	// Do any additional setup after loading the view.
}

- (void) updateArrayInstruments
{
    self.arrayInstruments = [self.composition.listInstuments sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCarousel:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    if (!self.arrayInstruments)
        [self updateArrayInstruments];
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
        label.textAlignment = UITextAlignmentCenter;
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
    NSArray *array = @[@"music_instruments.png", @"violin.png", @"viola.png"];
    if (id >= [array count])
        id = 0;
    return [array objectAtIndex:id];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    self.instrument = [self.arrayInstruments objectAtIndex:index];
    [self performSegueWithIdentifier:@"segueNotes" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueNotes"])
        [segue.destinationViewController setInstrument:self.instrument];
    [super prepareForSegue:segue sender:sender];
}

@end
