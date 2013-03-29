//
//  MSUListViewController.h
//  MusicStories
//
//  Created by Me Interactive on 25.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYIntroductionView.h"

@interface MSUListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MYIntroductionDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;
@end
