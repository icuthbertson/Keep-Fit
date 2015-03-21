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

@property long historyID; // ID of the history row.
@property long goalID; // ID of the goal the history row is for.
@property GoalStatus goalStatus; // Goal Status.
@property NSDate *startDate; // Date the status started.
@property NSDate *endDate; // Date the status ended.
@property double progressSteps; // Steps progress made during the status.
@property double progressStairs; // Stairs progress made during the status.

@end
