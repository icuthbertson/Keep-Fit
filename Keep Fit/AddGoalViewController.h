//
//  AddGoalViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 09/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeepFitGoal.h"
#import "Testing.h"

@interface AddGoalViewController : UIViewController /*<UIPickerViewDataSource, UIPickerViewDelegate>*/

@property KeepFitGoal *goal;
@property NSMutableArray *listGoalNames;
@property Testing *testing;

@end
