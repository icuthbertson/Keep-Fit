//
//  ScheduleViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 24/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Schedule.h"
#import "KeepFitGoal.h"
#import "Testing.h"

@interface ScheduleViewController : UIViewController

@property Schedule *schedule;
@property Testing *testing;
@property KeepFitGoal *viewGoal;
@property BOOL scheduleGoal;

@end
