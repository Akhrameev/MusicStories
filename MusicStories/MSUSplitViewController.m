//
//  MSUSplitViewController.m
//  MusicStories
//
//  Created by Me Interactive on 03.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import "MSUSplitViewController.h"
#import "MSUDetailViewController.h"
#import "MSUMasterViewController.h"

@interface MSUSplitViewController ()
@end

@implementation MSUSplitViewController

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
    //назначить DetailViewController делегатом этого класса
    self.delegate = (id)[[[self viewControllers] lastObject] topViewController];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueNotes"])
    {
        self.instrument = [sender instrumentForSegue];
        [segue.destinationViewController setInstrument:self.instrument];
    }
    [super prepareForSegue:segue sender:sender];
}
@end
