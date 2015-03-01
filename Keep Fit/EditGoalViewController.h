//
//  EditGoalViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 11/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeepFitGoal.h"
#import "Testing.h"

@interface EditGoalViewController : UIViewController

@property KeepFitGoal *editGoal; // Goal object that'll to taken back by the GoalList.
@property BOOL wasEdit; // Boolean to tell if there was an edit or not.
@property NSMutableArray *listGoalNames; // List of previous goal names to check against for duplicates.
@property Testing *testing; // Testing object for getting the date and time from.

@end
