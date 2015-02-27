//
//  ViewGoalViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 11/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeepFitGoal.h"
#import "Testing.h"

@interface ViewGoalViewController : UIViewController<UIAlertViewDelegate>

@property KeepFitGoal *viewGoal;
@property NSMutableArray *listGoalNames;
@property Testing *testing;
@property NSMutableArray *keepFitGoals;

-(IBAction)unwindToView:(UIStoryboardSegue *)segue;

@end
