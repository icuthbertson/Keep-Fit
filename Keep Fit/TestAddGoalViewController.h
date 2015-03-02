//
//  TestAddGoalViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 24/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeepFitGoal.h"

@interface TestAddGoalViewController : UIViewController

@property KeepFitGoal *goal;
@property NSMutableArray *listGoalNames;
@property NSDate *currentDate;

@end
