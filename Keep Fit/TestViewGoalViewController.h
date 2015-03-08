//
//  TestViewGoalViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 24/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeepFitGoal.h"
#import "TestSettings.h"
#import "Testing.h"

@interface TestViewGoalViewController : UIViewController

@property KeepFitGoal *viewGoal;
@property NSMutableArray *listGoalNames;
@property NSDate *currentDate;
@property NSMutableArray *keepFitGoals;
@property TestSettings *settings;

@property Testing *testing;

-(IBAction)unwindFromChangeTime:(UIStoryboardSegue *)segue;
-(IBAction)unwindFromSchedule:(UIStoryboardSegue *)segue;

@end
