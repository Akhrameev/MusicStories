//
//  MSUMasterViewController.h
//  MusicStories
//
//  Created by Me Interactive on 03.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument+Ext.h"
#import "MSUSplitViewController.h"
@class MSUDetailViewController;
@interface MSUMasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, instrumentForSegueDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) MSUDetailViewController *detailViewController;
@property (strong, nonatomic) Instrument *lastOpenedInstrument;
@end
