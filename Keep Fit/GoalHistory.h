//
//  GoalHistory.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 20/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeepFitGoal.h"

@interface GoalHistory : NSObject

@property long historyID;
@property long goalID;
@property GoalStatus goalStatus;
@property NSDate *startDate;
@property NSDate *endDate;
@property int progressSteps;
@property int progressStairs;

@end
