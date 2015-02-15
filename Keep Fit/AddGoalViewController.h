//
//  AddGoalViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 09/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeepFitGoal.h"

@interface AddGoalViewController : UIViewController

@property KeepFitGoal *goal;
@property NSMutableArray *listGoalNames;

@end
