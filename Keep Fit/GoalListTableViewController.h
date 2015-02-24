//
//  GoalListTableViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 09/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoalListTableViewController : UITableViewController

-(IBAction)unwindToList:(UIStoryboardSegue *)segue;
-(IBAction)unwindFromView:(UIStoryboardSegue *)segue;
-(IBAction)unwindFromSettings:(UIStoryboardSegue *)segue;
-(IBAction)unwindFromListSelection:(UIStoryboardSegue *)segue;
-(void)loadFromDB;

@property NSInteger listType;

@end
