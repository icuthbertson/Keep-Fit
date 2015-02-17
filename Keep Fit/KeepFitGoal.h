//
//  KeepFitGoal.h
//  Keep Fit
//
//  Created by Iain Cuthbertson on 09/02/2015.
//  Copyright (c) 2015 Iain Cuthbertson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeepFitGoal : NSObject

typedef NS_ENUM(NSInteger, GoalStatus) {
    Pending = 0,
    Active,
    Overdue,
    Suspended,
    Abandoned
};

typedef NS_ENUM(NSInteger, GoalType) {
    Steps = 0,
    Stairs,
    Both
};

@property NSInteger goalID;
@property NSString *goalName;
@property GoalStatus goalStatus;
@property GoalType goalType;
@property NSInteger goalAmountSteps;
@property NSInteger goalProgressSteps;
@property NSInteger goalAmountStairs;
@property NSInteger goalProgressStairs;
@property NSDate *goalCompletionDate;
@property NSDate *goalCreationDate;
@end
