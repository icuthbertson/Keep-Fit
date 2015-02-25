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

@interface ScheduleViewController : UIViewController

@property Schedule *schedule;
@property NSDate *currentTime;
@property KeepFitGoal *viewGoal;

@end
