//
//  ViewGoalViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 11/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeepFitGoal.h"
#import "TestSettings.h"
#import "Testing.h"

@interface ViewGoalViewController : UIViewController<UIAlertViewDelegate>

@property KeepFitGoal *viewGoal; // goal to be viewed.
@property NSMutableArray *listGoalNames; // list of goal names.
@property NSMutableArray *keepFitGoals; // array of goals.
@property TestSettings *settings;

@property Testing *testing;

-(IBAction)unwindToView:(UIStoryboardSegue *)segue; // Returning from edit view.
-(IBAction)unwindFromHistory:(UIStoryboardSegue *)segue;

@end
