//
//  TestGoalListTableViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 24/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestSettings.h"

@interface TestGoalListTableViewController : UITableViewController

-(IBAction)unwindToListTest:(UIStoryboardSegue *)segue;
-(IBAction)unwindFromViewTest:(UIStoryboardSegue *)segue;

@property TestSettings *settings;

@end
