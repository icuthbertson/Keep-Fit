//
//  AddGoalViewController.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 09/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//  Base of class from https://developer.apple.com/library/ios/referencelibrary/GettingStarted/RoadMapiOS/index.html#//apple_ref/doc/uid/TP40011343-CH2-SW1
//

#import <UIKit/UIKit.h>
#import "KeepFitGoal.h"
#import "Testing.h"
#import "Settings.h"

@interface AddGoalViewController : UIViewController <UITextFieldDelegate>/*<UIPickerViewDataSource, UIPickerViewDelegate>*/

@property KeepFitGoal *goal; // Goal object that'll to taken back by the GoalList.
@property NSMutableArray *listGoalNames; // List of previous goal names to check against for duplicates.

@property Testing *testing;
@property Settings *settings;

@end
