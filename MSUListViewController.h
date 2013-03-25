//
//  MSUListViewController.h
//  MusicStories
//
//  Created by Me Interactive on 25.03.13.
//  Copyright (c) 2013 Me Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSUListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) NSArray *tableData;               //Table data - there will be notes
@property (strong, nonatomic) NSMutableData *responseData;      //responseData to get large answers from server
@end
