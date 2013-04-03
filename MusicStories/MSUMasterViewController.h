//
//  MSUMasterViewController.h
//  MusicStories
//
//  Created by Me Interactive on 03.04.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MSUDetailViewController;
@interface MSUMasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) MSUDetailViewController *detailViewController;
@end
