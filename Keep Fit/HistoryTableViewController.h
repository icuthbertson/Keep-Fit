//
//  HistoryTableViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 20/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeepFitGoal.h"
#import "Testing.h"

@interface HistoryTableViewController : UITableViewController

@property KeepFitGoal *viewHistoryGoal; // Goal to show the history for.
@property Testing *testing; // Testng object for getting the current time and db names from.

@end
