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

@property KeepFitGoal *editGoal;
@property BOOL wasEdit;
@property NSMutableArray *listGoalNames;
@property Testing *testing;

@end
